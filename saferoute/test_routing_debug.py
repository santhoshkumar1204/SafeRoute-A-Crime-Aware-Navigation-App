import requests
import json

def test_backend_routing():
    url = "http://127.0.0.1:8000/api/safest-route"
    
    # Padi to Anna Nagar (Approximate coordinates)
    payload = {
        "source": {"lat": 13.1067, "lon": 80.1834},  # Padi
        "destination": {"lat": 13.0850, "lon": 80.2100}, # Anna Nagar
        "safety_factor": 5.0
    }
    
    try:
        print(f"Sending request to {url}...")
        response = requests.post(url, json=payload)
        
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            shortest_len = len(data.get("shortest_path", []))
            optimal_len = len(data.get("optimal_path", []))
            
            print(f"Shortest Path Points: {shortest_len}")
            print(f"Optimal Path Points: {optimal_len}")
            print(f"Shortest Distance: {data.get('shortest_distance')}")
            
            if shortest_len > 0:
                print(f"Sample Shortest: {data['shortest_path'][:2]}...")
            else:
                print("WARNING: Shortest path is EMPTY")
                
            if optimal_len > 0:
                print(f"Sample Optimal: {data['optimal_path'][:2]}...")
            else:
                print("WARNING: Optimal path is EMPTY")
        else:
            print(f"Error Response: {response.text}")
            
    except Exception as e:
        print(f"Request failed: {e}")

if __name__ == "__main__":
    test_backend_routing()
