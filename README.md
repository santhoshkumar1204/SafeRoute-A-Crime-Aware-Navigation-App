# SafeRoute-A-Crime-Aware-Navigation-App
<div align="center">
	<img src="https://placehold.co/600x150?text=SafeRoute+Logo" alt="SafeRoute Logo" width="60%"/>
</div>

# SafeRoute – Crime Aware Navigation App

> **Navigate Safely, Not Just Quickly.**

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18-blue?logo=react)](https://react.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-6.0-green?logo=mongodb)](https://www.mongodb.com/)
[![Machine Learning](https://img.shields.io/badge/Machine%20Learning-Enabled-yellow?logo=scikit-learn)](https://scikit-learn.org/)
[![Hackathon Project](https://img.shields.io/badge/Hackathon-Winner-orange)](https://github.com/santhoshkumar1204/SafeRoute-Crime-Aware-Navigation-App)

---

## 🚩 Problem Statement

Urban navigation apps prioritize the shortest or fastest route, often ignoring real-world safety concerns. In cities with high crime rates, users risk encountering unsafe areas, especially at night or in unfamiliar neighborhoods. There is a critical need for navigation that prioritizes personal safety over speed.

---

## 💡 Our Solution

SafeRoute leverages AI and real-time crime data to recommend the safest possible route. By analyzing historical crime incidents and applying advanced ML models, SafeRoute computes risk scores for every road segment, ensuring users avoid high-risk zones and travel with peace of mind.

---

## ✨ Key Features

- 🛡️ **Crime-Aware Routing:** Avoids high-risk areas using real crime data
- 🤖 **AI-Powered Risk Scoring:** ML models assess risk for each road segment
- 🗺️ **Interactive Map:** Visualizes safest routes and crime hotspots
- 🚨 **Real-Time Alerts:** Notifies users of nearby incidents
- 📊 **Analytics Dashboard:** Insights into city safety trends
- 🔒 **Privacy First:** No personal tracking or data sharing
- 🌐 **Multi-Modal Support:** Works for walking, driving, and public transport

---

## 🛠️ Tech Stack

**Frontend:**
- React.js
- TypeScript
- Tailwind CSS

**Backend:**
- Node.js (Express)
- Python (Flask/FastAPI for ML inference)

**Database:**
- MongoDB

**Machine Learning:**
- Scikit-learn, Pandas, NumPy
- Custom risk scoring models

**Algorithms:**
- Dijkstra / A* with risk weighting

---

## 🏗️ System Architecture

```mermaid
flowchart TD
		A[User] -->|Request Route| B[Frontend (React)]
		B -->|API Call| C[Backend (Node.js)]
		C -->|Fetch Data| D[MongoDB]
		C -->|ML Inference| E[Python ML Service]
		E -->|Risk Scores| C
		C -->|Safest Path| B
		B -->|Display| A
```

---

## 🔄 Project Flow

1. **User** enters source and destination in the app
2. **Frontend** sends request to backend
3. **Backend** fetches relevant road and crime data from MongoDB
4. **ML Service** computes risk scores for each segment
5. **Graph Algorithm** finds the safest path
6. **Frontend** displays the safest route and risk info
7. **User** receives real-time alerts and analytics

---

## 🤖 Machine Learning Model Explanation

- **Input:** Historical crime data (type, location, time, severity)
- **Processing:** Feature engineering (hotspot detection, time-based risk, etc.)
- **Model:** Supervised learning (Random Forest, Logistic Regression)
- **Output:** Risk score for each road segment
- **Continuous Learning:** Model retrains as new data arrives

---

## 🗺️ Graph Algorithm Used

- **Dijkstra / A\***: Modified to include risk as edge weights
- **Path Cost:** $\text{Total Cost} = \alpha \times \text{Distance} + \beta \times \text{Risk Score}$
- **Result:** Safest (not just shortest) path is recommended

---

## 🗄️ Database Design (MongoDB)

- **Collections:**
	- `users`: User profiles, preferences
	- `roads`: Road segments, geo-coordinates
	- `crimes`: Crime incidents (type, location, time, severity)
	- `routes`: Saved and historical routes
- **Indexes:** Geo-spatial for fast location queries

---

## ⚙️ Installation & Setup

```bash
# 1. Clone the repo
$ git clone https://github.com/santhoshkumar1204/SafeRoute-Crime-Aware-Navigation-App.git
$ cd SafeRoute-Crime-Aware-Navigation-App

# 2. Install frontend dependencies
$ npm install

# 3. Install backend & ML dependencies
$ pip install -r requirements.txt

# 4. Configure MongoDB (local or cloud)

# 5. Start the development servers
$ npm run dev      # Frontend
$ python train_model.py  # ML Model (if retraining needed)
```

---

## 📁 Folder Structure

```
SafeRoute-Crime-Aware-Navigation-App/
├── src/                  # Frontend source code
│   ├── components/       # React components
│   ├── pages/            # App pages
│   ├── contexts/         # React contexts
│   ├── hooks/            # Custom hooks
│   └── ...
├── models/               # ML models
├── crimedatasets/        # Crime data CSVs
├── processed_data/       # Cleaned/processed data
├── public/               # Static assets
├── train_model.py        # ML training script
├── requirements.txt      # Python dependencies
├── package.json          # Node dependencies
└── ...
```

---

## 📡 API Endpoints Overview

| Method | Endpoint                | Description                       |
|--------|------------------------|-----------------------------------|
| GET    | /api/routes            | Get safest route                  |
| POST   | /api/report            | Report new incident               |
| GET    | /api/analytics         | Get safety analytics              |
| GET    | /api/alerts            | Get real-time alerts              |
| POST   | /api/auth/signup       | User signup                       |
| POST   | /api/auth/login        | User login                        |

---

## 🚀 Future Enhancements

- Integrate live police and CCTV feeds
- Community-sourced incident reporting
- Personalized risk profiles
- Multi-city and global support
- Advanced anomaly detection in ML
- Mobile app (React Native)

---

## 👥 Team

> _Add your awesome team members here!_

---

## 🏆 Hackathon Impact

SafeRoute empowers urban commuters to make informed, safe travel decisions. By prioritizing safety, it has the potential to reduce crime exposure, increase public trust in navigation apps, and set a new standard for smart city mobility.

---

## 🖼️ Screenshots

<div align="center">
	<img src="https://placehold.co/400x250?text=Dashboard+Screenshot" alt="Dashboard Screenshot" width="45%"/>
	<img src="https://placehold.co/400x250?text=Map+Screenshot" alt="Map Screenshot" width="45%"/>
</div>

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

- Navigate to the desired file(s).
- Click the "Edit" button (pencil icon) at the top right of the file view.
- Make your changes and commit the changes.

**Use GitHub Codespaces**

- Navigate to the main page of your repository.
- Click on the "Code" button (green button) near the top right.
- Select the "Codespaces" tab.
- Click on "New codespace" to launch a new Codespace environment.
- Edit files directly within the Codespace and commit and push your changes once you're done.

## What technologies are used for this project?

This project is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS

## How can I deploy this project?

Simply open [Lovable](https://lovable.dev/projects/REPLACE_WITH_PROJECT_ID) and click on Share -> Publish.

## Can I connect a custom domain to my Lovable project?

Yes, you can!

To connect a domain, navigate to Project > Settings > Domains and click Connect Domain.

Read more here: [Setting up a custom domain](https://docs.lovable.dev/features/custom-domain#custom-domain)
