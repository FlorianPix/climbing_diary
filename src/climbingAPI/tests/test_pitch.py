import json
import requests


def test_create_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # Given a db with a spot and its multi_pitch_route, authentication and a 'CreatePitch'
    # When a post request with a 'CreatePitch' is sent to /pitch/route/{route_id}
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # Then the response status code is '201 Created'
    assert response.status_code == 201
    # Then the response contains the created pitch
    data = json.loads(response.text)
    for key in a_create_pitch_1.keys():
        assert data[key] == a_create_pitch_1[key]


def test_retrieve_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch and authentication
    # When a get request is sent to /pitch/{pitch_id}
    response = requests.get(pitch_url + f"/{pitch_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is the pitch with that id
    data = json.loads(response.text)
    assert data['_id'] == pitch_id
    for key in a_create_pitch_1.keys():
        assert data[key] == a_create_pitch_1[key]


def test_retrieve_pitch_non_existent_id(headers):
    # Given authentication and an empty db
    # When a get request is sent to /pitch/{non_existent_pitch_id}
    url = 'http://localhost:8000/pitch'
    response = requests.get(url + f"/649ec039e7d91048f28d5eb8", headers=headers)
    # Then the response status code is '404 Not found'
    assert response.status_code == 404


def test_retrieve_pitches_empty(headers):
    # Given authentication and an empty db
    # When a get request is sent to /pitch
    url = 'http://localhost:8000/pitch'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is an empty list
    data = json.loads(response.text)
    assert data == []


def test_retrieve_pitches(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route,
                             headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']


def test_update_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_update_pitch):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch and authentication
    # When a put request is sent to /pitch/{pitch_id}
    response = requests.put(pitch_url + f'/{pitch_id}', json=a_update_pitch, headers=headers)
    # Then the response is the updated_pitch
    data = json.loads(response.text)
    assert data['_id'] == pitch_id
    for key in a_update_pitch.keys():
        assert data[key] == a_update_pitch[key]


def test_delete_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch and authentication
    # When a delete request is sent to /pitch/{pitch_id}/route/{multi_pitch_route_id}
    response = requests.delete(pitch_url + f"/{pitch_id}/route/{multi_pitch_route_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the pitch is removed from the db
    response = requests.get(pitch_url + f"/{pitch_id}", headers=headers)
    assert response.status_code == 404


def test_delete_pitch_and_id_from_multi_pitch_route(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch and authentication
    # When a delete request is sent to /pitch/{pitch_id}/route/{multi_pitch_route_id}
    response = requests.delete(pitch_url + f"/{pitch_id}/route/{multi_pitch_route_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the pitch is removed from the db
    response = requests.get(pitch_url + f"/{pitch_id}", headers=headers)
    assert response.status_code == 404
    # Then the pitch id is removed from the route
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    data = json.loads(response.text)
    assert data['pitch_ids'] == []


def test_delete_pitch_and_its_ascents(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
    multi_pitch_route_url = 'http://localhost:8000/multi_pitch_route'
    response = requests.post(multi_pitch_route_url + f'/spot/{spot_id}', json=a_create_multi_pitch_route, headers=headers)
    data = json.loads(response.text)
    multi_pitch_route_id = data['_id']
    # create a pitch
    pitch_url = 'http://localhost:8000/pitch'
    response = requests.post(pitch_url + f"/route/{multi_pitch_route_id}", json=a_create_pitch_1, headers=headers)
    data = json.loads(response.text)
    pitch_id = data['_id']
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch + ascent and authentication
    # When a delete request is sent to /pitch/{pitch_id}/route/{multi_pitch_route_id}
    response = requests.delete(pitch_url + f"/{pitch_id}/route/{multi_pitch_route_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the pitch is removed from the db
    response = requests.get(pitch_url + f"/{pitch_id}", headers=headers)
    assert response.status_code == 404
    # Then the pitch id is removed from the route
    response = requests.get(multi_pitch_route_url + f"/{multi_pitch_route_id}", headers=headers)
    data = json.loads(response.text)
    assert data['pitch_ids'] == []
    # Then the ascent is removed from the db
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    assert response.status_code == 404
