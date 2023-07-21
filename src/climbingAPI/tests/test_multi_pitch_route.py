import json
import requests


def test_create_multi_pitch_route(headers, a_create_spot, a_create_multi_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # Given a db with a spot, authentication and a 'CreateMultiPitchRoute'
    # When a post request with a 'CreateMultiPitchRoute' is sent to /multi_pitch_route/spot/{spot_id}
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    # Then the response status code is '201 Created'
    assert response.status_code == 201
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Then the response contains the created multi pitch route
    data = json.loads(response.text)
    for key in a_create_multi_pitch_route.keys():
        assert data[key] == a_create_multi_pitch_route[key]


def test_retrieve_multi_pitch_route(headers, a_create_spot, a_create_multi_pitch_route):
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
    # Given a db with a spot, a multi pitch route and authentication
    # When a get request is sent to /multi_pitch_route/{multi_pitch_route_id}
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is the multi pitch route with that id
    data = json.loads(response.text)
    assert data['_id'] == multi_pitch_route_id
    for key in a_create_multi_pitch_route.keys():
        assert data[key] == a_create_multi_pitch_route[key]


def test_retrieve_multi_pitch_route_non_existent_id(headers):
    # Given authentication and an empty db
    # When a get request is sent to /multi_pitch_route/{non_existent_multi_pitch_route_id}
    url = 'http://localhost:8000/multi_pitch_route'
    response = requests.get(url + f"/649ec039e7d91048f28d5eb8", headers=headers)
    # Then the response status code is '404 Not found'
    assert response.status_code == 404


def test_retrieve_multi_pitch_routes_empty(headers):
    # Given authentication and an empty db
    # When a get request is sent to /multi_pitch_route
    url = 'http://localhost:8000/multi_pitch_route'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is an empty list
    data = json.loads(response.text)
    assert data == []


def test_retrieve_multi_pitch_routes(headers, a_create_spot, a_create_multi_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Given a db with a spot and its multi_pitch_route and authentication
    # When a get request is sent to /multi_pitch_route
    response = requests.get(multi_pitch_route_url, headers=headers)
    # Then the response code is '200 OK'
    assert response.status_code == 200
    data = json.loads(response.text)
    # Then the response is a list with one multi pitch route
    assert len(data) == 1
    assert multi_pitch_route_id == data[0]['_id']
    for key in a_create_multi_pitch_route.keys():
        assert data[0][key] == a_create_multi_pitch_route[key]


def test_update_multi_pitch_route(headers, a_create_spot, a_create_multi_pitch_route, a_update_multi_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Given a db with a spot and its multi_pitch_route and authentication
    # When a put request with an 'UpdateMultiPitchRoute' is sent to /multi_pitch_route/{multi_pitch_route_id}
    response = requests.put(multi_pitch_route_url + f'/{multi_pitch_route_id}', json=a_update_multi_pitch_route, headers=headers)
    # Then the response is the updated_ascent
    data = json.loads(response.text)
    assert data['_id'] == multi_pitch_route_id
    for key in a_update_multi_pitch_route.keys():
        assert data[key] == a_update_multi_pitch_route[key]


def test_delete_multi_pitch_route(headers, a_create_spot, a_create_multi_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Given a db with a spot, a multi pitch route and authentication
    # When a delete request is sent to /multi_pitch_route/{multi_pitch_route_id}/spot/{spot_id}
    response = requests.delete(multi_pitch_route_url + f"/{multi_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    print(response.json())
    assert response.status_code == 200
    # Then the single pitch route is removed from the db
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    assert response.status_code == 404


def test_delete_multi_pitch_route_and_id_from_spot(headers, a_create_spot, a_create_multi_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Given a db with a spot, a multi pitch route and authentication
    # When a delete request is sent to /multi_pitch_route/{multi_pitch_route_id}/spot/{spot_id}
    response = requests.delete(multi_pitch_route_url + f"/{multi_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the multi pitch route is removed from the db
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    assert response.status_code == 404
    # Then the multi pitch route id is removed from the spot
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    data = json.loads(response.text)
    assert data['multi_pitch_route_ids'] == []


def test_delete_multi_pitch_route_and_its_pitches_and_ascents(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_pitch_2, a_create_ascent):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create multi pitch route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create two pitches
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
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
    response = requests.post(ascent_url + f"/pitch/{pitch_2_id}", json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_2_id = data['_id']
    # Given a db with a spot, a multi pitch route and its pitches and ascents and authentication
    # When a delete request is sent to /multi_pitch_route/{multi_pitch_route_id}/spot/{spot_id}
    response = requests.delete(multi_pitch_route_url + f"/{multi_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the multi pitch route is removed from the db
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    assert response.status_code == 404
    # Then the multi pitch route id is removed from the spot
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    data = json.loads(response.text)
    assert data['multi_pitch_route_ids'] == []
    # Then its pitches are removed from the db
    response = requests.get(ascent_url + f"/{ascent_1_id}", headers=headers)
    assert response.status_code == 404
    response = requests.get(ascent_url + f"/{ascent_2_id}", headers=headers)
    assert response.status_code == 404
    # Then its pitches ascents are removed from the db
    response = requests.get(pitch_url + f"/{pitch_1_id}", headers=headers)
    assert response.status_code == 404
    response = requests.get(pitch_url + f"/{pitch_2_id}", headers=headers)
    assert response.status_code == 404
