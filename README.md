<div align="center">
  <img src="https://placehold.co/600x150?text=SafeRoute+Logo" alt="SafeRoute Logo" width="60%"/>
</div>

# SafeRoute – Crime Aware Navigation App

> **Navigate Safely. Not Just Quickly.**

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python)](https://www.python.org/)
[![React](https://img.shields.io/badge/React-18-blue?logo=react)](https://react.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange?logo=firebase)](https://firebase.google.com/)
[![Graph Algorithms](https://img.shields.io/badge/Algorithms-Dijkstra%20%2F%20A*-%23009688)]()
[![Hackathon Project](https://img.shields.io/badge/Hackathon-Project-orange)]()

---

## 🚩 Problem Statement

Most navigation applications prioritize the **shortest** or **fastest** route, ignoring real-world safety risks.

Users may unknowingly pass through:
- High-crime zones  
- Accident-prone intersections  
- Unsafe neighborhoods during late hours  

There is a clear need for a navigation system that prioritizes **personal safety** over speed.

---

## 💡 Our Solution

SafeRoute is a crime-aware navigation system that recommends the **safest optimized route** instead of simply the shortest one.

By combining:

- Historical crime data
- Risk scoring logic
- Graph-based pathfinding algorithms

SafeRoute calculates safety-weighted routes and guides users through lower-risk areas.

---

## ✨ Key Features

- 🛡️ Crime-aware route optimization  
- 🗺️ Safest path computation using Dijkstra / A*  
- 🔥 Crime hotspot visualization  
- 📍 Location-based risk scoring  
- 📊 Safety analytics dashboard  
- ⚡ Optimized shortest-safe route recommendation  

---

## 🛠️ Tech Stack

### Frontend
- React.js
- TypeScript
- Tailwind CSS

### Backend
- Python (API layer & routing logic)

### Database
- Firebase (Cloud Firestore)

### Algorithms
- Dijkstra’s Algorithm  
- A* Search Algorithm  
- Risk-weighted path optimization  

---

## 🏗️ System Architecture

```mermaid
flowchart TD
    A[User] --> B[React Frontend]
    B -->|Route Request| C[Python Backend]
    C -->|Fetch Crime Data| D[Firebase Firestore]
    C -->|Risk Calculation| E[Risk Engine]
    E -->|Weighted Graph| F[Path Optimizer]
    F -->|Safest Route| C
    C -->|Response| B
    B --> A
