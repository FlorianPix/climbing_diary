import json
import requests


def test_create_spot(headers, a_create_spot):
    # Given an empty db, authentication and a 'CreateSpot'
    # When a post request with a 'CreateSpot' is sent to /spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    # Then the response status code is '201 Created'
    assert response.status_code == 201
    # Then the response contains the created spot
    data = json.loads(response.text)
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]


def test_create_two_spots_with_same_name_and_location(headers, a_create_spot, a_create_spot2):
    # Given an empty db, authentication and a 'CreateSpot'
    # When two post requests with the same 'CreateSpot' are sent to /spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    assert response.status_code == 201
    response = requests.post(url, json=a_create_spot2, headers=headers)
    # Then the second response status code should be '409 Conflict'
    assert response.status_code == 409


def test_create_two_spots_with_same_name_but_different_location(headers, a_create_spot, a_create_spot3):
    # Given an empty db, authentication and a 'CreateSpot'
    # When two post requests with the same 'CreateSpot' are sent to /spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    assert response.status_code == 201
    response = requests.post(url, json=a_create_spot3, headers=headers)
    # Then the second response status code should be '201 Created'
    assert response.status_code == 201


def test_retrieve_spots_empty(headers):
    # Given an empty db and authentication
    # When a get request is sent to /spot
    url = 'http://localhost:8000/spot'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is []
    data = json.loads(response.text)
    assert data == []


def test_retrieve_spot(headers, a_create_spot):
    # creating a spot is already tested in test_create_spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # Given authentication and a db with one spot
    # When a get request is sent to /spot/{spot_id}
    response = requests.get(url+f"/{spot_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is the spot with that id
    data = json.loads(response.text)
    assert data['_id'] == spot_id
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]


def test_retrieve_spot_non_existent_id(headers, a_create_spot):
    # Given authentication and an empty db
    # When a get request is sent to /spot/{non_existent_spot_id}
    url = 'http://localhost:8000/spot'
    response = requests.get(url+f"/649ec039e7d91048f28d5eb8", headers=headers)
    # Then the response status code is '404 Not found'
    assert response.status_code == 404


def test_retrieve_spots(headers, a_create_spot):
    # creating a spot is already tested in test_create_spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    assert response.status_code == 201
    data = json.loads(response.text)
    spot_id = data['_id']
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]
    # Given authentication and a db with one spot
    # When a get request is sent to /spot
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is a list containing the spot
    data = json.loads(response.text)
    assert len(data) == 1
    assert data[0]['_id'] == spot_id
    for key in keys:
        assert data[0][key] == a_create_spot[key]


def test_update_spot(headers, a_create_spot, a_update_spot):
    # creating a spot is already tested in test_create_spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    assert response.status_code == 201
    data = json.loads(response.text)
    spot_id = data['_id']
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]
    # Given authentication and a db with one spot
    # When a put request is sent to /spot/{spot_id}
    response = requests.put(url+f'/{spot_id}', json=a_update_spot, headers=headers)
    # Then the response is the updated_spot
    data = json.loads(response.text)
    assert data['_id'] == spot_id
    for key in a_update_spot.keys():
        assert data[key] == a_update_spot[key]


def test_delete_spot(headers, a_create_spot):
    # creating a spot is already tested in test_create_spot
    url = 'http://localhost:8000/spot'
    response = requests.post(url, json=a_create_spot, headers=headers)
    assert response.status_code == 201
    data = json.loads(response.text)
    spot_id = data['_id']
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]
    # Given authentication and a db with one spot
    # When a delete request is sent to /spot/{spot_id}
    response = requests.delete(url+f'/{spot_id}', headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the response is the deleted spot
    data = json.loads(response.text)
    assert data['_id'] == spot_id
    for key in keys:
        assert data[key] == a_create_spot[key]


def test_delete_spot_and_id_from_trip(headers, a_create_trip, a_update_trip, a_create_spot):
    # create a trip
    # creating a trip is already tested in test_trip/test_create_trip
    trip_url = 'http://localhost:8000/trip'
    response = requests.post(trip_url, json=a_create_trip, headers=headers)
    data = json.loads(response.text)
    trip_id = data['_id']
    # create a spot
    # creating a spot is already tested in test_create_spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # add the spot id to the trip
    # updating a trip is already tested in test_trip/test_update_trip
    trip_url = 'http://localhost:8000/trip'
    a_update_trip['spot_ids'] = [spot_id]
    requests.put(trip_url + f"/{trip_id}", json=a_update_trip, headers=headers)
    response = requests.get(trip_url + f"/{trip_id}", headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    assert data['spot_ids'] == [spot_id]
    # Given authentication and a db with one trip with a spot
    # When a delete request is sent to /spot/{spot_id}
    response = requests.delete(spot_url + f'/{spot_id}', headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the response is the deleted spot
    data = json.loads(response.text)
    assert data['_id'] == spot_id
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]
    # Then spot is not in the db anymore
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    assert response.status_code == 404
    # Then the trip does not have the spot_id anymore
    response = requests.get(trip_url + f"/{trip_id}", headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    assert data['spot_ids'] == []


def test_delete_spot_and_all_its_multi_pitch_routes_pitches_ascents(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch, a_create_pitch_2, a_create_ascent, a_create_ascent2):
    # Given authentication and a db with one spot that has one multi pitch route with two pitches and one ascent each
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    a_create_spot['multi_pitch_route_ids'] = [multi_pitch_route_id]
    # create two pitches
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch, headers=headers)
    data = json.loads(response.text)
    pitch_1_id = data['_id']
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_2, headers=headers)
    data = json.loads(response.text)
    pitch_2_id = data['_id']
    # create one ascent for each pitch
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f"/pitch/{pitch_1_id}", json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_1_id = data['_id']
    response = requests.post(ascent_url + f"/pitch/{pitch_2_id}", json=a_create_ascent2, headers=headers)
    data = json.loads(response.text)
    ascent_2_id = data['_id']
    # When a delete request is sent to /spot/{spot_id}
    response = requests.delete(spot_url + f'/{spot_id}', headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the response is the deleted spot
    data = json.loads(response.text)
    assert data['_id'] == spot_id
    keys = list(a_create_spot.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_spot[key]
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    assert response.status_code == 404
    # Then the spots multi pitch routes are deleted
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    assert response.status_code == 404
    # Then the multi pitch routes pitches are deleted
    response = requests.get(pitch_url + f"/{pitch_1_id}", headers=headers)
    assert response.status_code == 404
    response = requests.get(pitch_url + f"/{pitch_2_id}", headers=headers)
    assert response.status_code == 404
    # Then the pitches ascents are deleted
    response = requests.get(ascent_url + f"/{ascent_1_id}", headers=headers)
    assert response.status_code == 404
    response = requests.get(ascent_url + f"/{ascent_2_id}", headers=headers)
    assert response.status_code == 404
