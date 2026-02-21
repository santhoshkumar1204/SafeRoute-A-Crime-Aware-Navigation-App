# SafeRoute – Crime-Aware Public Transport Navigation

> **Enhancing Public Transport Safety Using AI & TN MTC Data**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python&logoColor=white)](https://www.python.org/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?logo=firebase&logoColor=white)](https://firebase.google.com/)
[![XGBoost](https://img.shields.io/badge/ML-XGBoost-success)](https://xgboost.readthedocs.io/)
[![OpenStreetMap](https://img.shields.io/badge/Maps-OpenStreetMap-lightgrey?logo=openstreetmap&logoColor=black)](https://www.openstreetmap.org/)

---

## 🚩 Problem Statement

The Tamil Nadu Metropolitan Transport Corporation (TN MTC) provides extensive public transportation datasets. However, a significant gap exists in commuter safety intelligence.

### The Challenges

- Current systems provide bus schedules but ignore **personal safety risks** at stops and terminals.
- Commuters lack guidance on the safest walking paths to and from transit hubs.
- High-crime areas can deter the usage of public transport, especially during off-peak hours.

SafeRoute addresses these societal concerns by improving the **accessibility, safety, and confidence** of public transportation users.

---

## 💡 Our Solution

SafeRoute integrates **TN MTC transport datasets** with predictive safety intelligence:

- **Historical Crime Correlation** – Links crime density with transit locations.
- **AI Risk Prediction** – Evaluates safety levels for boarding, alighting, and walking segments.
- **Geospatial Optimization** – Uses OpenStreetMap for safety-first path computation.
- **Safe Commute Planning** – Suggests routes that minimize exposure to high-risk zones.

---

## 🚀 Core Vision

> **Make public transport not only accessible — but safe and predictable.**

SafeRoute empowers women commuters, students, night-shift workers, and first-time travelers by embedding protective intelligence into their daily journeys.

---

## 🛠️ Technical Ecosystem

### 📱 Mobile Frontend – Flutter

SafeRoute is built as a modular, cross-platform mobile application using **Flutter**.

- OpenStreetMap integration for route visualization  
- AI-powered safety heatmaps  
- Real-time safety alerts  
- SOS emergency button with live location sharing  
- Women Safety Mode prioritizing verified safe corridors  

---

### ☁️ Database & Cloud – Firebase

Firebase provides scalable, real-time infrastructure.

**Cloud Firestore stores:**
- TN MTC route & stop data  
- Crime records  
- Community reports  
- User safety logs  

**Firebase Services:**
- Authentication (secure login & emergency contacts)  
- Cloud Functions (ML inference orchestration)  

---

### 🧠 Machine Learning – XGBoost

SafeRoute uses an **XGBoost Classifier** for spatio-temporal crime risk prediction.

**Model Inputs:**
- Latitude & Longitude  
- Time of Day  
- Day of Week  
- Historical Crime Density  
- Proximity to Bus Stops & Terminals  

**Model Output:**
- Normalized **Risk Score (0–1)** for each road segment and bus stop.

This enables fast real-time inference during navigation.

---

## 🗺️ Risk-Weighted Route Optimization

Traditional navigation minimizes only **Distance**.

SafeRoute minimizes: Path Cost = Distance + (Risk Score × Safety Factor) 

### Engine Details

- Modified **Dijkstra’s Algorithm**
- Risk-aware **A\*** heuristic search
- Safety-weighted graph modeling

This ensures slightly longer but significantly safer first- and last-mile connectivity.

---

## ✨ Key Features

| Feature | Description |
|----------|------------|
| 🚌 Safe Bus Stop Selection | Ranks boarding and alighting points by safety score |
| 🔥 AI Safety Heatmaps | Visualizes predicted hotspot regions |
| 👩 Women Safety Mode | Filters routes to prioritize safer corridors |
| 🧠 Context-Aware Risk | Adjusts safety scoring based on time |
| 🔄 Smart Rerouting | Updates path when new risk is detected |
| 🤝 Community Reports | Enables crowdsourced safety feedback |

---

---

## 🔄 Application Flow

1. User selects destination and preferred MTC bus route.  
2. TN MTC route and stop data are retrieved from Firebase.  
3. Crime data for surrounding walking segments is fetched.  
4. XGBoost model predicts risk scores.  
5. Risk-weighted engine computes the safest combined journey.  
6. Flutter app renders the optimized route with safety overlays and real-time alerts.  

---

## 🧪 ML Model Setup

### Structure

- `models/` → Trained XGBoost artifacts  
- `train_model.py` → End-to-end training pipeline  
- `backend/` → Real-time inference integration  
- `requirements.txt` → Python dependencies  

---

### Setup & Training

```bash
pip install -r requirements.txt
python train_model.py

---

## 📁 Project Structure

```text
SafeRoute/
├── flutter_app/          # Flutter mobile application
├── backend/              # Python backend service
├── models/               # Trained ML artifacts
├── datasets/             # Crime & transport data (local only)
├── train_model.py        # ML training script
├── requirements.txt
└── README.md
```

## 📡 Core API Endpoints

| Method | Endpoint            | Description                         |
|--------|--------------------|-------------------------------------|
| GET    | /api/safest-route  | Returns safest optimized commute    |
| GET    | /api/hotspots      | Returns AI heatmap data             |
| GET    | /api/safe-stops    | Returns ranked bus stops            |
| POST   | /api/report        | Submit safety incident              |

---

## 🌍 Societal Impact

SafeRoute enhances TN MTC public transport by:

- Increasing commuter confidence  
- Reducing exposure to unsafe zones  
- Encouraging public transport adoption  
- Supporting safer urban mobility ecosystems  

By combining transport intelligence with predictive safety analytics, SafeRoute transforms public transit into a smarter, data-driven, and safer commuting experience.

## 🏗️ System Architecture

```mermaid
flowchart TD
    A["Flutter App"] -->|Route Request| B["Python Backend"]
    B -->|Fetch TN MTC Data| C["Firebase Firestore"]
    B -->|Fetch Crime Data| C
    B -->|Predict Risk| D["XGBoost Model"]
    D -->|Risk Scores| B
    B -->|Risk-Weighted Graph| E["Dijkstra / A-Star Engine"]
    E -->|Optimized Safe Route| B
    B -->|Response| A




