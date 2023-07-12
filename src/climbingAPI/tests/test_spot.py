import json
import requests


def test_get_spots(headers):
    url = 'http://localhost:8000/spot'
    response = requests.get(url, headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    assert data == []


def test_create_spot(headers):
    url = 'http://localhost:8000/spot'
    spot = {
      "comment": "Great spot close to a lake with solid holds but kinda hard to reach.",
      "coordinates": [50.746036, 10.642666],
      "distance_parking": 120,
      "distance_public_transport": 120,
      "location": "Deutschland, Thüringen, Thüringer Wald",
      "name": "Falkenstein",
      "rating": 5
    }
    response = requests.post(url, json=spot, headers=headers)
    assert response.status_code == 201
    data = json.loads(response.text)
    spot_id = data['_id']
    for key in spot.keys():
        assert data[key] == spot[key]

    response = requests.get(url+f"/{spot_id}", headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    for key in spot.keys():
        assert data[key] == spot[key]
