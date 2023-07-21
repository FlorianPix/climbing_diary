import requests


def test_get_default():
    url = 'http://localhost:8000/'
    response = requests.get(url)
    assert response.status_code == 404
    assert response.json() == {"detail": "Not Found"}


def test_get_docs():
    url = 'http://localhost:8000/docs'
    response = requests.get(url)
    assert response.status_code == 200


def test_no_token():
    url = 'http://localhost:8000/spot'
    response = requests.get(url)
    assert response.status_code == 403
    assert response.json() == {"detail": "Missing bearer token"}