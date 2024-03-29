import pytest
import json
import requests

from app.models.grading_system import GradingSystem

# testing user password database:
testingUsers = {
    'test@test.de': '1ZxU&9^e2Oi@x9Fl'
}


def getUserToken(user_name):
    # client id and secret come from LogIn (Test Client)! which has password enabled under "Client > Advanced > Grant Types > Tick Password"
    url = 'https://climbing-diary.eu.auth0.com/oauth/token'
    headers = {'content-type': 'application/json'}
    password = testingUsers[user_name]
    parameter = {"client_id": "FnK5PkMpjuoH5uJ64X70dlNBuBzPVynE",
                 "client_secret": "MSnQoFF28iCMZgKsfKiBdvOgErzA9cy3FKTUcfYuDkfpKJSlR4RN1pJuj5lQlsb6",
                 "audience": 'climbing-diary-API',
                 "grant_type": "password",
                 "username": user_name,
                 "password": password, "scope": "openid"}
    # do the equivalent of a CURL request from https://auth0.com/docs/quickstart/backend/python/02-using#obtaining-an-access-token-for-testing
    responseDICT = json.loads(requests.post(url, json=parameter, headers=headers).text)
    return responseDICT['access_token']


def getUserTokenHeaders(user_name='test@test.de'):
    return {'authorization': "Bearer " + getUserToken(user_name)}


@pytest.fixture(scope="session")
def headers():
    # setup
    headers = getUserTokenHeaders()
    yield headers
    #  teardown


@pytest.fixture(autouse=True)
def empty_db(headers):
    # setup
    url = 'http://localhost:8000/admin'
    requests.delete(url, headers=headers)
    #  teardown


@pytest.fixture()
def a_create_trip():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-000000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "a comment",
        "end_date": "2022-10-08",
        "name": "a name",
        "start_date": "2022-10-06",
        "rating": 5
    }


@pytest.fixture()
def a_update_trip():
    yield {
        "media_ids": [],
        "spot_ids": [],
        "comment": "a comment",
        "end_date": "2022-10-08",
        "name": "a name",
        "start_date": "2022-10-06",
        "rating": 5
    }


@pytest.fixture()
def a_create_spot():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-100000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "media_ids": [],
        "single_pitch_route_ids": [],
        "multi_pitch_route_ids": [],
        "user_id": "",
        "comment": "a comment",
        "coordinates": [50.746036, 10.642666],
        "distance_parking": 120,
        "distance_public_transport": 120,
        "location": "a location",
        "name": "a name",
        "rating": 5
    }


@pytest.fixture()
def a_create_spot2():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-100000000002",
        "updated": "2022-10-06T20:13:16.816000",
        "media_ids": [],
        "single_pitch_route_ids": [],
        "multi_pitch_route_ids": [],
        "user_id": "",
        "comment": "a comment",
        "coordinates": [50.746036, 10.642666],
        "distance_parking": 120,
        "distance_public_transport": 120,
        "location": "a location",
        "name": "a name",
        "rating": 5
    }


@pytest.fixture()
def a_create_spot3():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-100000000003",
        "updated": "2022-10-06T20:13:16.816000",
        "media_ids": [],
        "single_pitch_route_ids": [],
        "multi_pitch_route_ids": [],
        "user_id": "",
        "comment": "a comment",
        "coordinates": [51.746036, 11.642666],
        "distance_parking": 120,
        "distance_public_transport": 120,
        "location": "a location",
        "name": "a name",
        "rating": 5
    }


@pytest.fixture()
def a_update_spot():
    yield {
      "comment": "Updated comment",
      "coordinates": [1.1, 2.2],
      "distance_parking": 1,
      "distance_public_transport": 2,
      "location": "Updated location",
      "name": "Updated name",
      "rating": 1
    }


@pytest.fixture()
def a_create_multi_pitch_route():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-200000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "a comment",
        "location": "a location",
        "name": "a name",
        "rating": 5
    }


@pytest.fixture()
def a_update_multi_pitch_route():
    yield {
      "comment": "updated comment",
      "location": "updated location",
      "name": "updated name",
      "rating": 1
    }


@pytest.fixture()
def a_create_single_pitch_route():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-300000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "a comment",
        "location": "a location",
        "name": "a name",
        "rating": 5,
        "grade": {"grade": "5a", "system": 3},
        "length": 40
    }


@pytest.fixture()
def a_update_single_pitch_route():
    yield {
      "comment": "updated comment",
      "location": "updated location",
      "name": "updated name",
      "rating": 1,
      "grade": {"grade": "IV", "system": 6},
      "length": 32
    }


@pytest.fixture()
def a_create_pitch():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-400000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "Top Pitch",
        "grade": {"grade": "6a", "system": 3},
        "length": 35,
        "name": "Pitch 1",
        "num": 1,
        "rating": 5
    }


@pytest.fixture()
def a_create_pitch_2():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-400000000002",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "Great Pitch",
        "grade": {"grade": "5a", "system": 3},
        "length": 21,
        "name": "Pitch 2",
        "num": 2,
        "rating": 4
    }


@pytest.fixture()
def a_update_pitch():
    yield {
      "comment": "updated comment",
      "grade": {"grade": "IV", "system": 6},
      "length": 12,
      "name": "updated name",
      "num": 2,
      "rating": 1
    }


@pytest.fixture()
def a_create_ascent():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-500000000001",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "a comment",
        "date": "2022-10-06",
        "style": 0,
        "type": 3
    }


@pytest.fixture()
def a_create_ascent2():
    yield {
        "_id": "410bb603-ef0c-41cc-a1af-500000000002",
        "updated": "2022-10-06T20:13:16.816000",
        "user_id": "",
        "comment": "a comment",
        "date": "2022-10-06",
        "style": 0,
        "type": 3
    }


@pytest.fixture()
def a_update_ascent():
    yield {
      "media_ids": [],
      "comment": "updated comment",
      "date": "2021-02-14",
      "style": 1,
      "type": 2
    }
