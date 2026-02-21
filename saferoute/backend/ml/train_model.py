import pandas as pd
import numpy as np
import xgboost as xgb
from sklearn.metrics import roc_auc_score, f1_score, accuracy_score, precision_score, recall_score, confusion_matrix
from sklearn.model_selection import KFold
from sklearn.preprocessing import LabelEncoder
import pickle
import os
import time

# Configuration
TRAIN_PATH = 'crimedatasets/crime_train_full_merged.csv'
TEST_PATH = 'crimedatasets/crime_test_full_merged.csv'
MODEL_DIR = 'models'

def load_and_preprocess():
    print("🧠 STEP 1 — LOADING DATA")
    train_df = pd.read_csv(TRAIN_PATH)
    test_df = pd.read_csv(TEST_PATH)
    
    print(f"Train samples: {len(train_df)}")
    print(f"Test samples: {len(test_df)}")
    
    # 🧠 STEP 2 — TARGET CONSTRUCTION (DENSITY-BASED SPATIO-TEMPORAL RISK)
    print("🧠 STEP 2 — CONSTRUCTING DENSITY-BASED TARGET (Spatio-Temporal Context)")
    
    # Calculate density per (segment_id, is_night) context from train data
    train_counts = train_df.groupby(['segment_id', 'is_night']).size().reset_index(name='density')
    
    # Calculate threshold (75th percentile) strictly from train data
    threshold = train_counts['density'].quantile(0.75)
    print(f"75th Percentile Density Threshold (Train): {threshold:.2f}")
    
    # Identify context-specific High Risk IDs
    # Fix: Compare the density column specifically
    high_risk_rows = train_counts[train_counts['density'] >= threshold]
    high_risk_contexts = set(
        high_risk_rows.apply(lambda x: f"{x['segment_id']}_{int(x['is_night'])}", axis=1)
    )
    
    # Map back to datasets
    def assign_target(df):
        # Optimized mapping
        return df.apply(lambda x: 1 if f"{x['segment_id']}_{int(x['is_night'])}" in high_risk_contexts else 0, axis=1)

    train_df['target'] = assign_target(train_df)
    test_df['target'] = assign_target(test_df)
    
    print(f"Target distribution (Train): {train_df['target'].mean():.2%}")
    print(f"Target distribution (Test): {test_df['target'].mean():.2%}")

    # 🧠 STEP 3 — FEATURE ENGINEERING
    print("🧠 STEP 3 — FEATURE ENGINEERING")
    
    # Select available features, removing target-derivatives and leakage
    # We drop columns that are 100% NaN based on previous analysis
    cols_to_drop = [
        'severity', 'datetime', 'year', 'crime_type', 'segment_id',
        'crime_density_30d', 'crime_density_365d', 'night_risk_factor',
        'weekend_risk_factor', 'seasonal_factor', 'start_lat', 'start_lon',
        'end_lat', 'end_lon', 'road_type', 'lighting_score', 'cctv_density',
        'traffic_level', 'population_density', 'police_station_distance',
        'count' # Remove the count column to avoid circularity (used to define target)
    ]
    
    # Encoding Categorical
    le = LabelEncoder()
    train_df['district_enc'] = le.fit_transform(train_df['district'])
    test_df['district_enc'] = le.transform(test_df['district'])
    
    if not os.path.exists(MODEL_DIR): os.makedirs(MODEL_DIR)
    with open(f'{MODEL_DIR}/label_encoder_district.pkl', 'wb') as f:
        pickle.dump(le, f)
    with open(f'{MODEL_DIR}/high_risk_contexts.pkl', 'wb') as f:
        pickle.dump(high_risk_contexts, f)

    # Handle growth_factor and other numeric columns for inf/null
    for df in [train_df, test_df]:
        # Replace inf with 0 or a large number (capping)
        # We'll use 0 since we fillna(0) anyway
        df.replace([np.inf, -np.inf], 0, inplace=True)
        df.fillna(0, inplace=True)

    features = [
        'latitude', 'longitude', 'hour', 'weekday', 'month', 
        'season', 'is_weekend', 'is_night', 'district_enc'
    ]
    
    # Handle growth_factor if it exists and has variation
    if 'growth_factor' in train_df.columns:
        features.append('growth_factor')

    return train_df, test_df, features

def train_model(train_df, test_df, features):
    print("🧠 STEP 4 — TRAINING XGBOOST")
    
    X_train = train_df[features]
    y_train = train_df['target']
    X_test = test_df[features]
    y_test = test_df['target']
    
    # Class imbalance handling
    neg = len(y_train) - y_train.sum()
    pos = y_train.sum()
    spw = neg / pos if pos > 0 else 1
    
    print(f"Positive samples: {pos}, Negative samples: {neg}, scale_pos_weight: {spw:.2f}")
    
    kf = KFold(n_splits=5, shuffle=True, random_state=42)
    start_time = time.time()
    
    # Best model selection via simple fold for this task
    train_idx, val_idx = next(kf.split(X_train))
    
    params = {
        'objective': 'binary:logistic',
        'eval_metric': 'auc',
        'learning_rate': 0.1,
        'max_depth': 6,
        'n_estimators': 600,
        'scale_pos_weight': spw,
        'random_state': 42,
        'early_stopping_rounds': 20
    }
    
    model = xgb.XGBClassifier(**params)
    model.fit(
        X_train.iloc[train_idx], y_train.iloc[train_idx],
        eval_set=[(X_train.iloc[val_idx], y_train.iloc[val_idx])],
        verbose=100
    )
    
    duration = time.time() - start_time
    
    # 📊 STEP 5 — EVALUATION ON TEST SET ONLY
    print("\n📊 STEP 5 — EVALUATING ON TEST SET ONLY")
    y_pred_prob = model.predict_proba(X_test)[:, 1]
    y_pred = (y_pred_prob > 0.5).astype(int)
    
    auc = roc_auc_score(y_test, y_pred_prob)
    f1 = f1_score(y_test, y_pred)
    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred)
    rec = recall_score(y_test, y_pred)
    cm = confusion_matrix(y_test, y_pred)
    
    print("\n--- PERFORMANCE SUMMARY ---")
    print(f"ROC-AUC:   {auc:.4f}")
    print(f"F1 Score:  {f1:.4f}")
    print(f"Accuracy:  {acc:.4f}")
    print(f"Precision: {prec:.4f}")
    print(f"Recall:    {rec:.4f}")
    print(f"Confusion Matrix:\n{cm}")
    
    if auc > 0.90:
        print("⚠️ Potential leakage detected.")
        
    # 💾 STEP 6-7 — SAVE MODEL & FEATURES
    print(f"\n💾 STEP 7 — SAVING MODEL TO /{MODEL_DIR}/")
    with open(f'{MODEL_DIR}/crime_risk_model_production.pkl', 'wb') as f:
        pickle.dump(model, f)
    with open(f'{MODEL_DIR}/feature_columns_production.pkl', 'wb') as f:
        pickle.dump(features, f)
        
    return model, features, auc, f1, duration

def test_inference(model, features):
    print("\n⚙️ STEP 8 — TESTING INFERENCE")
    def predict_risk(lat, lon, hour, weekday, month, season, is_weekend, is_night, district_enc, growth_factor=0):
        # Build input properly matching feature list
        input_data = {
            'latitude': lat, 'longitude': lon, 'hour': hour,
            'weekday': weekday, 'month': month, 'season': season,
            'is_weekend': is_weekend, 'is_night': is_night,
            'district_enc': district_enc
        }
        if 'growth_factor' in features:
            input_data['growth_factor'] = growth_factor
            
        input_df = pd.DataFrame([input_data])[features]
        
        start = time.time()
        risk_score = model.predict_proba(input_df)[0, 1]
        latency = (time.time() - start) * 1000
        
        risk_level = "High" if risk_score > 0.5 else "Low"
        return {"risk_score": float(risk_score), "risk_level": risk_level, "latency_ms": latency}

    # Chennai central sample
    res = predict_risk(13.08, 80.27, 22, 5, 12, 4, 1, 1, 0)
    print(f"Sample prediction: {res}")
    return res['latency_ms']

if __name__ == "__main__":
    train_df, test_df, features = load_and_preprocess()
    model, features, auc, f1, duration = train_model(train_df, test_df, features)
    latency = test_inference(model, features)
    
    print("\n--- FINAL OUTPUT ---")
    print(f"Train samples: {len(train_df)}")
    print(f"Test samples:  {len(test_df)}")
    print(f"Final ROC-AUC: {auc:.4f}")
    print(f"Final F1:      {f1:.4f}")
    print(f"Training duration: {duration:.2f}s")
    print(f"Inference latency:  {latency:.2f}ms")
    
    print("\nSegment-level crime risk model trained successfully for SafeRoute routing.")

