import pytest
import json
import requests


# testing user password database:
testingUsers = {
    'test@test.de': '1ZxU&9^e2Oi@x9Fl'
}


def getUserToken(user_name):
    #  client id and secret come from LogIn (Test Client)! which has password enabled under "Client > Advanced > Grant Types > Tick Password"
    url = 'https://climbing-diary.eu.auth0.com/oauth/token'
    headers = {'content-type': 'application/json'}
    password = testingUsers[user_name]
    parameter = {"client_id": "FnK5PkMpjuoH5uJ64X70dlNBuBzPVynE",
                 "client_secret": "MSnQoFF28iCMZgKsfKiBdvOgErzA9cy3FKTUcfYuDkfpKJSlR4RN1pJuj5lQlsb6",
                 "audience": 'climbing-diary-API',
                 "grant_type": "password",
                 "username": user_name,
                 "password": password, "scope": "openid"}
    #  do the equivalent of a CURL request from https://auth0.com/docs/quickstart/backend/python/02-using#obtaining-an-access-token-for-testing
    responseDICT = json.loads(requests.post(url, json=parameter, headers=headers).text)
    return responseDICT['access_token']


def getUserTokenHeaders(user_name='test@test.de'):
    return {'authorization': "Bearer " + getUserToken(user_name)}


@pytest.fixture()
def headers():
    # setup
    url = 'http://localhost:8000/admin'
    headers = getUserTokenHeaders()
    requests.delete(url, headers=headers)
    yield headers
    #  teardown
