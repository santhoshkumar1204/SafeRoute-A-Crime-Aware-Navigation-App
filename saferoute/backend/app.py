from __future__ import annotations

import math
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from ml.predict import predict_risk
from ml.risk_engine import compute_path_risk
from routing.astar import astar
from routing.dijkstra import dijkstra
from routing.graph_utils import (
    get_graph_data,
    find_nearest_node,
    path_to_coordinates,
)


class Location(BaseModel):
    lat: float
    lon: float


class SafestRouteRequest(BaseModel):
    source: Location
    destination: Location
    safety_factor: float = 1.0


class PathPoint(BaseModel):
    lat: float
    lon: float


class RiskZone(BaseModel):
    lat: float
    lon: float
    risk_score: float


class SafestRouteResponse(BaseModel):
    shortest_path: List[PathPoint]
    optimal_path: List[PathPoint]
    shortest_distance: float
    optimal_cost: float
    risk_zones: List[RiskZone]


app = FastAPI(title="SafeRoute Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/test-model")
def test_model() -> dict:
    try:
        result = predict_risk(
            lat=13.0827,
            lon=80.2707,
            hour=22,
            weekday=5,
            month=12,
            season=4,
            is_weekend=1,
            is_night=1,
            district_enc=0,
            growth_factor=0.0,
        )
        return {"risk_score": result["risk_score"], "risk_level": result["risk_level"]}
    except FileNotFoundError as exc:
        raise HTTPException(status_code=503, detail=str(exc))
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/test-routing")
def test_routing(safety_factor: float = 1.0) -> dict:
    graph, nodes = get_graph_data()

    source_node = "A"
    target_node = "D"

    print("routing_test_start", source_node, target_node, safety_factor)

    shortest_distance, shortest_path_nodes = dijkstra(graph, source_node, target_node)

    print("routing_dijkstra_done", shortest_distance, len(shortest_path_nodes))

    optimal_cost, optimal_path_nodes = astar(
        graph,
        nodes,
        source_node,
        target_node,
        safety_factor,
    )

    print("routing_astar_done", optimal_cost, len(optimal_path_nodes))

    return {
        "shortest_distance": shortest_distance,
        "shortest_path_nodes": shortest_path_nodes,
        "optimal_cost": optimal_cost,
        "optimal_path_nodes": optimal_path_nodes,
    }


@app.post("/api/safest-route", response_model=SafestRouteResponse)
def safest_route(payload: SafestRouteRequest) -> SafestRouteResponse:
    print(f"API CALLED WITH: {payload}")
    try:
        graph, nodes = get_graph_data()

        source_node = find_nearest_node(payload.source.lat, payload.source.lon, nodes)
        target_node = find_nearest_node(payload.destination.lat, payload.destination.lon, nodes)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    print(
        "safest_route_start",
        payload.source.lat,
        payload.source.lon,
        payload.destination.lat,
        payload.destination.lon,
        payload.safety_factor,
    )

    shortest_distance, shortest_path_nodes = dijkstra(graph, source_node, target_node)

    print("safest_route_dijkstra", shortest_distance, len(shortest_path_nodes))

    optimal_cost, optimal_path_nodes = astar(
        graph,
        nodes,
        source_node,
        target_node,
        payload.safety_factor,
    )

    print("safest_route_astar", optimal_cost, len(optimal_path_nodes))

    shortest_path_coords = path_to_coordinates(shortest_path_nodes, nodes)
    optimal_path_coords = path_to_coordinates(optimal_path_nodes, nodes)

    risk_threshold = 0.6
    risk_zones: List[RiskZone] = []

    for i in range(len(optimal_path_nodes) - 1):
        current_node = optimal_path_nodes[i]
        next_node = optimal_path_nodes[i + 1]

        for neighbor, distance, risk_score in graph.get(current_node, []):
            if neighbor != next_node:
                continue
            if risk_score <= risk_threshold:
                continue

            lat1, lon1 = nodes[current_node]
            lat2, lon2 = nodes[next_node]
            mid_lat = (lat1 + lat2) / 2
            mid_lon = (lon1 + lon2) / 2

            risk_zones.append(
                RiskZone(
                    lat=mid_lat,
                    lon=mid_lon,
                    risk_score=risk_score,
                )
            )
            break

    optimal_cost_value = 0.0
    for i in range(len(optimal_path_nodes) - 1):
        current_node = optimal_path_nodes[i]
        next_node = optimal_path_nodes[i + 1]

        for neighbor, distance, risk_score in graph.get(current_node, []):
            if neighbor != next_node:
                continue

            optimal_cost_value += compute_path_risk(distance, risk_score, payload.safety_factor)
            break

    print(
        "safest_route_done",
        shortest_distance,
        optimal_cost_value,
        len(risk_zones),
    )

    if math.isinf(shortest_distance) or math.isnan(shortest_distance):
        shortest_distance = 0.0

    if math.isinf(optimal_cost_value) or math.isnan(optimal_cost_value):
        optimal_cost_value = 0.0

    # Ensure risk zones have valid scores
    valid_risk_zones = []
    for rz in risk_zones:
        if math.isinf(rz.risk_score) or math.isnan(rz.risk_score):
            rz.risk_score = 0.0
        if math.isinf(rz.lat) or math.isnan(rz.lat) or math.isinf(rz.lon) or math.isnan(rz.lon):
            continue
        valid_risk_zones.append(rz)

    return SafestRouteResponse(
        shortest_path=[PathPoint(**p) for p in shortest_path_coords],
        optimal_path=[PathPoint(**p) for p in optimal_path_coords],
        shortest_distance=shortest_distance,
        optimal_cost=optimal_cost_value,
        risk_zones=valid_risk_zones,
    )
