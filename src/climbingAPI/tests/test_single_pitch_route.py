import json
import requests


def test_create_single_pitch_route(headers, a_create_spot, a_create_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # Given a db with a spot, authentication and a 'CreateSinglePitchRoute'
    # When a post request with a 'CreateSinglePitchRoute' is sent to /single_pitch_route/spot/{spot_id}
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route, headers=headers)
    # Then the response status code is '201 Created'
    assert response.status_code == 201
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # Then the response contains the created single pitch route
    data = json.loads(response.text)
    keys = list(a_create_single_pitch_route.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_single_pitch_route[key]
    # Then the created single pitch route can be retrieved with a get request
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    keys = list(a_create_single_pitch_route.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_single_pitch_route[key]


def test_retrieve_single_pitch_route(headers, a_create_spot, a_create_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route, headers=headers)
    assert response.status_code == 201
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    data = json.loads(response.text)
    keys = list(a_create_single_pitch_route.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_single_pitch_route[key]
    # Given a db with a spot, authentication and a 'CreateSinglePitchRoute'
    # When a get request is sent to /single_pitch_route/{single_pitch_route_id}
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    # Then the response code is '200 OK'
    assert response.status_code == 200
    data = json.loads(response.text)
    # Then the response is the single pitch route with the specified id
    assert single_pitch_route_id == data['_id']
    keys = list(a_create_single_pitch_route.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[key] == a_create_single_pitch_route[key]


def test_retrieve_single_pitch_route_non_existent_id(headers):
    # Given authentication and an empty db
    # When a get request is sent to /single_pitch_route/{non_existent_single_pitch_route_id}
    url = 'http://localhost:8000/single_pitch_route'
    response = requests.get(url + f"/649ec039e7d91048f28d5eb8", headers=headers)
    # Then the response status code is '404 Not found'
    assert response.status_code == 404


def test_retrieve_single_pitch_routes_empty(headers):
    # Given authentication and an empty db
    # When a get request is sent to /single_pitch_route
    url = 'http://localhost:8000/single_pitch_route'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is an empty list
    data = json.loads(response.text)
    assert data == []


def test_retrieve_single_pitch_routes(headers, a_create_spot, a_create_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route, headers=headers)
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # Given a db with a spot and its single_pitch_route and authentication
    # When a get request is sent to /single_pitch_route
    response = requests.get(single_pitch_route_url, headers=headers)
    # Then the response code is '200 OK'
    assert response.status_code == 200
    data = json.loads(response.text)
    # Then the response is a list with one single pitch route
    assert len(data) == 1
    assert single_pitch_route_id == data[0]['_id']
    keys = list(a_create_single_pitch_route.keys())
    keys.remove("updated")
    keys.remove("user_id")
    for key in keys:
        assert data[0][key] == a_create_single_pitch_route[key]


def test_update_single_pitch_route(headers, a_create_spot, a_create_single_pitch_route, a_update_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a single pitch route
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route, headers=headers)
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # Given a db with a spot, authentication and a 'UpdateSinglePitchRoute'
    # When a put request is sent to /single_pitch_route/{single_pitch_route_id}
    response = requests.put(single_pitch_route_url + f"/{single_pitch_route_id}", json=a_update_single_pitch_route, headers=headers)
    # Then the response code is '200 OK'
    assert response.status_code == 200
    data = json.loads(response.text)
    # Then the response is the updated single pitch route
    assert single_pitch_route_id == data['_id']
    for key in a_update_single_pitch_route.keys():
        assert data[key] == a_update_single_pitch_route[key]
    # Then the updated single pitch route can be retrieved with a get request
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    assert response.status_code == 200
    data = json.loads(response.text)
    assert single_pitch_route_id == data['_id']
    for key in a_update_single_pitch_route.keys():
        assert data[key] == a_update_single_pitch_route[key]


def test_delete_single_pitch_route(headers, a_create_spot, a_create_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a single pitch route
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route, headers=headers)
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # Given a db with a spot, a single pitch route and authentication
    # When a delete request is sent to /single_pitch_route/{single_pitch_route_id}/spot/{spot_id}
    response = requests.delete(single_pitch_route_url + f"/{single_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the single pitch route is removed from the db
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    assert response.status_code == 404


def test_delete_single_pitch_route_and_id_from_spot(headers, a_create_spot, a_create_single_pitch_route):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a single pitch route
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route,
                             headers=headers)
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # Given a db with a spot, a single pitch route and authentication
    # When a delete request is sent to /single_pitch_route/{single_pitch_route_id}/spot/{spot_id}
    response = requests.delete(single_pitch_route_url + f"/{single_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the single pitch route is removed from the db
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    assert response.status_code == 404
    # Then the single pitch route id is removed from the spot
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    data = json.loads(response.text)
    assert data['single_pitch_route_ids'] == []


def test_delete_single_pitch_route_and_its_ascents(headers, a_create_spot, a_create_single_pitch_route, a_create_ascent):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a single pitch route
    single_pitch_route_url = 'http://localhost:8000/single_pitch_route'
    response = requests.post(single_pitch_route_url + f'/spot/{spot_id}', json=a_create_single_pitch_route,
                             headers=headers)
    data = json.loads(response.text)
    single_pitch_route_id = data['_id']
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/route/{single_pitch_route_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot, its single pitch route and ascent and authentication
    # When a delete request is sent to /single_pitch_route/{single_pitch_route_id}/spot/{spot_id}
    response = requests.delete(single_pitch_route_url + f"/{single_pitch_route_id}/spot/{spot_id}", headers=headers)
    # Then the response status code is '200 Ok'
    assert response.status_code == 200
    # Then the single pitch route is removed from the db
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    assert response.status_code == 404
    # Then the single pitch route id is removed from the spot
    response = requests.get(spot_url + f"/{spot_id}", headers=headers)
    data = json.loads(response.text)
    assert data['single_pitch_route_ids'] == []
    # Then its ascents are removed from the db
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    assert response.status_code == 404

