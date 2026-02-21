def compute_path_risk(distance: float, risk_score: float, safety_factor: float) -> float:
    return distance + (risk_score * safety_factor)

