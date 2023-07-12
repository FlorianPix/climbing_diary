import json
import requests


def test_create_ascent_of_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
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
    # Given a db with a spot and its multi_pitch_route + pitch, authentication and a 'CreateAscent'
    # When a post request with a 'CreateAscent' is sent to /ascent/pitch/{pitch_id}
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    # Then the response status code is '201 Created'
    assert response.status_code == 201
    # Then the response contains the created spot
    data = json.loads(response.text)
    for key in a_create_ascent.keys():
        assert data[key] == a_create_ascent[key]


def test_retrieve_ascent(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
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
    # When a get request is sent to /ascent/{ascent_id}
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is the ascent with that id
    data = json.loads(response.text)
    assert data['_id'] == ascent_id
    for key in a_create_ascent.keys():
        assert data[key] == a_create_ascent[key]


def test_retrieve_ascent_non_existent_id(headers):
    # Given authentication and an empty db
    # When a get request is sent to /ascent/{non_existent_ascent_id}
    url = 'http://localhost:8000/ascent'
    response = requests.get(url + f"/649ec039e7d91048f28d5eb8", headers=headers)
    # Then the response status code is '404 Not found'
    assert response.status_code == 404


def test_retrieve_ascents_empty(headers):
    # Given authentication and an empty db
    # When a get request is sent to /ascent
    url = 'http://localhost:8000/ascent'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is an empty list
    data = json.loads(response.text)
    assert data == []


def test_retrieve_ascents(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
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
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch + ascent and authentication
    # When a get request is sent to /ascent
    url = 'http://localhost:8000/ascent'
    response = requests.get(url, headers=headers)
    # Then the response status code is '200 OK'
    assert response.status_code == 200
    # Then the response is a list containing the ascent id
    data = json.loads(response.text)
    assert len(data) == 1
    assert data[0]['_id'] == ascent_id
    for key in a_create_ascent.keys():
        assert data[0][key] == a_create_ascent[key]


def test_update_ascent(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent, a_update_ascent):
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
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch + ascent and authentication
    # When a put request is sent to /ascent/{ascent_id}
    response = requests.put(ascent_url + f'/{ascent_id}', json=a_update_ascent, headers=headers)
    # Then the response is the updated_ascent
    data = json.loads(response.text)
    assert data['_id'] == ascent_id
    for key in a_update_ascent.keys():
        assert data[key] == a_update_ascent[key]


def test_delete_ascent(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
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
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch + ascent and authentication
    # When a delete request is sent to /ascent/{ascent_id}
    response = requests.delete(ascent_url + f"/{ascent_id}/pitch/{pitch_id}", headers=headers)
    # Then the response status code is '204 No Content'
    assert response.status_code == 204
    # Then the ascent is removed from the db
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    assert response.status_code == 404


def test_delete_ascent_and_id_from_pitch(headers, a_create_spot, a_create_multi_pitch_route, a_create_pitch_1, a_create_ascent):
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
    # create an ascent
    ascent_url = 'http://localhost:8000/ascent'
    response = requests.post(ascent_url + f'/pitch/{pitch_id}', json=a_create_ascent, headers=headers)
    data = json.loads(response.text)
    ascent_id = data['_id']
    # Given a db with a spot and its multi_pitch_route + pitch + ascent and authentication
    # When a delete request is sent to /ascent/{ascent_id}
    response = requests.delete(ascent_url + f"/{ascent_id}/pitch/{pitch_id}", headers=headers)
    # Then the response status code is '204 No Content'
    assert response.status_code == 204
    # Then the ascent is removed from the db
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    assert response.status_code == 404
    # Then the ascent id is removed from the pitch
    response = requests.get(pitch_url + f"/{pitch_id}", headers=headers)
    data = json.loads(response.text)
    assert data['ascent_ids'] == []


def test_delete_ascent_and_id_from_single_pitch_route(headers, a_create_spot, a_create_single_pitch_route, a_create_ascent):
    # create a spot
    spot_url = 'http://localhost:8000/spot'
    response = requests.post(spot_url, json=a_create_spot, headers=headers)
    data = json.loads(response.text)
    spot_id = data['_id']
    # create a multi_pitch_route
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
    # Given a db with a spot and its single_pitch_route + ascent and authentication
    # When a delete request is sent to /ascent/{ascent_id}
    response = requests.delete(ascent_url + f"/{ascent_id}/route/{single_pitch_route_id}", headers=headers)
    # Then the response status code is '204 No Content'
    assert response.status_code == 204
    # Then the ascent is removed from the db
    response = requests.get(ascent_url + f"/{ascent_id}", headers=headers)
    assert response.status_code == 404
    # Then the ascent id is removed from the pitch
    response = requests.get(single_pitch_route_url + f"/{single_pitch_route_id}", headers=headers)
    data = json.loads(response.text)
    assert data['ascent_ids'] == []
