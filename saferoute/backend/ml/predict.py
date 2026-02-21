import time
import pickle
from typing import Dict, Any

import pandas as pd

from config import MODEL_DIR


_model = None
_features = None


def load_model_and_features():
    global _model, _features
    if _model is None or _features is None:
        model_path = MODEL_DIR / "crime_risk_model_production.pkl"
        features_path = MODEL_DIR / "feature_columns_production.pkl"

        if not model_path.exists() or not features_path.exists():
            raise FileNotFoundError(
                f"Model files not found in {MODEL_DIR}. "
                f"Expected crime_risk_model_production.pkl and feature_columns_production.pkl."
            )

        with open(model_path, "rb") as f:
            _model = pickle.load(f)
        with open(features_path, "rb") as f:
            _features = pickle.load(f)
    return _model, _features


def predict_risk(
    lat: float,
    lon: float,
    hour: int,
    weekday: int,
    month: int,
    season: int,
    is_weekend: int,
    is_night: int,
    district_enc: int,
    growth_factor: float = 0.0,
) -> Dict[str, Any]:
    print("ML MODEL CALLED")
    model, features = load_model_and_features()

    input_data = {
        "latitude": lat,
        "longitude": lon,
        "hour": hour,
        "weekday": weekday,
        "month": month,
        "season": season,
        "is_weekend": is_weekend,
        "is_night": is_night,
        "district_enc": district_enc,
    }
    if "growth_factor" in features:
        input_data["growth_factor"] = growth_factor

    input_df = pd.DataFrame([input_data])[features]

    start = time.time()
    risk_score = model.predict_proba(input_df)[0, 1]
    latency = (time.time() - start) * 1000

    risk_level = "High" if risk_score > 0.5 else "Low"
    return {"risk_score": float(risk_score), "risk_level": risk_level, "latency_ms": latency}
