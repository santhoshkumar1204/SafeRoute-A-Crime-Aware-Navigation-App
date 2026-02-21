import requests
import json

url = "http://127.0.0.1:8000/api/safest-route"
payload = {
    "source": {"lat": 13.0827, "lon": 80.2707},
    "destination": {"lat": 13.0604, "lon": 80.2496},
    "safety_factor": 10.0
}
headers = {
    "Content-Type": "application/json"
}

try:
    response = requests.post(url, json=payload, headers=headers)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
