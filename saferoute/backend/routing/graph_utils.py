from __future__ import annotations

import csv
import os
from datetime import datetime
from math import radians, sin, cos, sqrt, atan2
from typing import Dict, List, Tuple

from ml.predict import predict_risk


Graph = Dict[str, List[Tuple[str, float, float]]]
NodeCoordinates = Dict[str, Tuple[float, float]]


_GRAPH_CACHE: Tuple[Graph, NodeCoordinates] | None = None
_RISK_CACHE: Dict[Tuple[float, float, int, int, int, int, int, int, int], float] = {}


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0

    phi1 = radians(lat1)
    phi2 = radians(lat2)
    d_phi = radians(lat2 - lat1)
    d_lambda = radians(lon2 - lon1)

    a = sin(d_phi / 2) ** 2 + cos(phi1) * cos(phi2) * sin(d_lambda / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return r * c


def _compute_edge_risk(lat: float, lon: float) -> float:
    now = datetime.utcnow()
    hour = now.hour
    weekday = now.weekday()
    month = now.month

    season = (month % 12 + 3) // 3
    is_weekend = 1 if weekday >= 5 else 0
    is_night = 1 if hour < 6 or hour >= 20 else 0
    district_enc = 0
    growth_factor = 0.0

    cache_key = (
        round(lat, 6),
        round(lon, 6),
        hour,
        weekday,
        month,
        season,
        is_weekend,
        is_night,
        district_enc,
    )

    if cache_key in _RISK_CACHE:
        # print("risk_cache_hit", cache_key)
        return _RISK_CACHE[cache_key]

    try:
        # print("risk_model_call", lat, lon, hour, weekday, month)
        result = predict_risk(
            lat=lat,
            lon=lon,
            hour=hour,
            weekday=weekday,
            month=month,
            season=season,
            is_weekend=is_weekend,
            is_night=is_night,
            district_enc=district_enc,
            growth_factor=growth_factor,
        )
        risk_score = float(result["risk_score"])
    except (FileNotFoundError, Exception) as e:
        # print(f"Risk model error: {e}")
        risk_score = 0.5

    _RISK_CACHE[cache_key] = risk_score
    # print("risk_cache_store", cache_key, risk_score)
    return risk_score


def _load_csv_graph() -> Tuple[Graph, NodeCoordinates] | None:
    # Attempt to load from ../../assets/structured_bus_segments.csv
    # Relative to this file (saferoute/backend/routing/graph_utils.py)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(current_dir, "..", "..", "assets", "structured_bus_segments.csv")
    
    if not os.path.exists(csv_path):
        print(f"CSV graph data not found at: {csv_path}")
        return None

    nodes: NodeCoordinates = {}
    graph: Graph = {}

    try:
        with open(csv_path, mode="r", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            count = 0
            for row in reader:
                try:
                    s_id = row["start_stop_id"]
                    s_lat = float(row["start_lat"])
                    s_lon = float(row["start_lon"])
                    
                    e_id = row["end_stop_id"]
                    e_lat = float(row["end_lat"])
                    e_lon = float(row["end_lon"])

                    # Add nodes
                    if s_id not in nodes:
                        nodes[s_id] = (s_lat, s_lon)
                        graph[s_id] = []
                    if e_id not in nodes:
                        nodes[e_id] = (e_lat, e_lon)
                        graph[e_id] = []

                    # Calculate edge properties
                    dist = haversine_distance(s_lat, s_lon, e_lat, e_lon)
                    mid_lat = (s_lat + e_lat) / 2
                    mid_lon = (s_lon + e_lon) / 2
                    risk = _compute_edge_risk(mid_lat, mid_lon)

                    # Add edges (undirected for now, assuming bus routes can be walked both ways?)
                    # Bus routes are directed. But for navigation we might assume walking?
                    # If this is "Safe Route", it might be walking or driving.
                    # Let's assume undirected for connectivity.
                    graph[s_id].append((e_id, dist, risk))
                    graph[e_id].append((s_id, dist, risk))
                    count += 1
                except (ValueError, KeyError) as e:
                    continue
            
            print(f"Loaded {len(nodes)} nodes and {count} edges from CSV")
            if len(nodes) > 0:
                return graph, nodes
    except Exception as e:
        print(f"Error loading CSV graph: {e}")
    
    return None


def _default_nodes() -> NodeCoordinates:
    return {
        "A": (13.0827, 80.2707),
        "B": (13.0600, 80.2496),
        "C": (13.0500, 80.2800),
        "D": (13.0700, 80.3000),
    }


def _default_edges() -> List[Tuple[str, str]]:
    return [
        ("A", "B"),
        ("A", "C"),
        ("B", "C"),
        ("C", "D"),
        ("B", "D"),
    ]


def get_graph_data() -> Tuple[Graph, NodeCoordinates]:
    global _GRAPH_CACHE

    if _GRAPH_CACHE is not None:
        return _GRAPH_CACHE

    # Try loading from CSV first
    csv_data = _load_csv_graph()
    if csv_data is not None:
        _GRAPH_CACHE = csv_data
        return _GRAPH_CACHE

    print("Falling back to default mock graph")
    nodes = _default_nodes()
    graph: Graph = {node_id: [] for node_id in nodes.keys()}

    for start, end in _default_edges():
        lat1, lon1 = nodes[start]
        lat2, lon2 = nodes[end]

        distance = haversine_distance(lat1, lon1, lat2, lon2)
        mid_lat = (lat1 + lat2) / 2
        mid_lon = (lon1 + lon2) / 2
        risk_score = _compute_edge_risk(mid_lat, mid_lon)

        graph[start].append((end, distance, risk_score))
        graph[end].append((start, distance, risk_score))

    _GRAPH_CACHE = (graph, nodes)
    return _GRAPH_CACHE


def find_nearest_node(lat: float, lon: float, nodes: NodeCoordinates) -> str:
    best_node = None
    best_distance = float("inf")

    for node_id, (n_lat, n_lon) in nodes.items():
        d = haversine_distance(lat, lon, n_lat, n_lon)
        if d < best_distance:
            best_distance = d
            best_node = node_id

    if best_node is None:
        raise ValueError("No nodes available in graph")

    return best_node


def path_to_coordinates(path: List[str], nodes: NodeCoordinates) -> List[Dict[str, float]]:
    coordinates = []
    for node_id in path:
        lat, lon = nodes[node_id]
        coordinates.append({"lat": lat, "lon": lon})
    return coordinates


def build_graph() -> Graph:
    graph, _ = get_graph_data()
    return graph
