from __future__ import annotations

import heapq
from typing import Dict, List, Tuple

Graph = Dict[str, List[Tuple[str, float, float]]]


def dijkstra(graph: Graph, source: str, target: str) -> Tuple[float, List[str]]:
    print("DIJKSTRA EXECUTED")
    queue: List[Tuple[float, str, List[str]]] = []
    heapq.heappush(queue, (0.0, source, []))

    visited = set()

    while queue:
        distance, node, path = heapq.heappop(queue)

        if node in visited:
            continue

        visited.add(node)
        path = path + [node]

        if node == target:
            return distance, path

        for neighbor, edge_distance, _risk_score in graph.get(node, []):
            if neighbor in visited:
                continue
            new_distance = distance + edge_distance
            heapq.heappush(queue, (new_distance, neighbor, path))

    return 0.0, []
