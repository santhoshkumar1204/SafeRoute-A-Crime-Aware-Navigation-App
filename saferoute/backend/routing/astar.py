from __future__ import annotations

import heapq
from typing import Dict, List, Tuple

from .graph_utils import NodeCoordinates, haversine_distance

Graph = Dict[str, List[Tuple[str, float, float]]]


def astar(
    graph: Graph,
    nodes: NodeCoordinates,
    source: str,
    target: str,
    safety_factor: float,
) -> Tuple[float, List[str]]:
    print("ASTAR EXECUTED")
    queue: List[Tuple[float, float, str, List[str]]] = []
    heapq.heappush(queue, (0.0, 0.0, source, []))

    best_g: Dict[str, float] = {source: 0.0}

    while queue:
        f_score, g_score, node, path = heapq.heappop(queue)

        if node == target:
            return g_score, path + [node]

        path = path + [node]

        for neighbor, distance, risk_score in graph.get(node, []):
            edge_cost = distance + (risk_score * safety_factor)
            tentative_g = g_score + edge_cost

            if neighbor in best_g and tentative_g >= best_g[neighbor]:
                continue

            best_g[neighbor] = tentative_g

            n_lat, n_lon = nodes[neighbor]
            t_lat, t_lon = nodes[target]
            heuristic = haversine_distance(n_lat, n_lon, t_lat, t_lon)

            f = tentative_g + heuristic
            heapq.heappush(queue, (f, tentative_g, neighbor, path))

    return 0.0, []
