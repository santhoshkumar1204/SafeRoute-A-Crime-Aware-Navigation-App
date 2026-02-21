# SafeRoute -- Crime-Aware Public Transport Navigation

> **Enhancing Public Transport Safety Using AI & TN MTC Data**

------------------------------------------------------------------------

## 🚩 Problem Statement

The Tamil Nadu Metropolitan Transport Corporation (TN MTC) provides
extensive public transportation datasets. However, a significant gap
exists in commuter safety intelligence.

### The Challenges

-   Current systems provide bus schedules but ignore **personal safety
    risks** at stops and terminals.
-   Commuters lack guidance on the safest walking paths to and from
    transit hubs.
-   High-crime areas can deter the usage of public transport, especially
    during off-peak hours.

SafeRoute addresses these societal concerns by improving the
**accessibility, safety, and confidence** of public transportation
users.

------------------------------------------------------------------------

## 💡 Our Solution

SafeRoute integrates **TN MTC transport datasets** with predictive
safety intelligence:

-   Historical Crime Correlation\
-   AI Risk Prediction using XGBoost\
-   Geospatial Optimization using OpenStreetMap\
-   Risk-Weighted Route Computation

------------------------------------------------------------------------

## 🛠️ Technical Stack

-   **Mobile App:** Flutter\
-   **Backend:** Python\
-   **Database:** Firebase (Cloud Firestore)\
-   **Machine Learning:** XGBoost\
-   **Maps:** OpenStreetMap\
-   **Algorithms:** Modified Dijkstra / A\*

------------------------------------------------------------------------

## 🏗️ System Architecture

Flutter App → Python Backend → Firebase + XGBoost → Risk Engine → Safe
Route Output

------------------------------------------------------------------------

## 🔄 Application Flow

1.  User selects destination and preferred MTC bus route.\
2.  TN MTC route and stop data are retrieved from Firebase.\
3.  Crime data for surrounding walking segments is fetched.\
4.  XGBoost model predicts risk scores.\
5.  Risk-weighted engine computes the safest combined journey.\
6.  Flutter app renders the optimized route with safety overlays and
    alerts.

------------------------------------------------------------------------

## 🧪 ML Model Setup

### Structure

-   `models/` → Trained XGBoost artifacts\
-   `train_model.py` → Training pipeline\
-   `backend/` → Real-time inference integration\
-   `requirements.txt` → Python dependencies

### Setup & Training

pip install -r requirements.txt\
python train_model.py

### What This Process Does

-   Processes spatio-temporal crime datasets\
-   Trains the XGBoost classifier\
-   Stores production-ready model artifacts in `models/`

### Notes

-   Raw datasets are excluded from version control.\
-   Temporary outputs are ignored.\
-   Refer to `.gitignore` for excluded files.

------------------------------------------------------------------------

## 📁 Project Structure

SafeRoute/\
├── flutter_app/\
├── backend/\
├── models/\
├── datasets/\
├── train_model.py\
├── requirements.txt\
└── README.md

------------------------------------------------------------------------

## 📡 Core API Endpoints

GET /api/safest-route → Returns safest optimized commute\
GET /api/hotspots → Returns AI heatmap data\
GET /api/safe-stops → Returns ranked bus stops\
POST /api/report → Submit safety incident

------------------------------------------------------------------------

## 🌍 Societal Impact

SafeRoute enhances TN MTC public transport by:

-   Increasing commuter confidence\
-   Reducing exposure to unsafe zones\
-   Encouraging public transport adoption\
-   Supporting safer urban mobility ecosystems

By combining transport intelligence with predictive safety analytics,
SafeRoute transforms public transit into a smarter and safer commuting
experience.

------------------------------------------------------------------------

## 📄 License

MIT License


