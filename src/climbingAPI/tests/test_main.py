from fastapi.testclient import TestClient
from main import get_application

app = get_application()
client = TestClient(app)


def test_read_main():
    response = client.get("/")
    assert response.status_code == 404
    assert response.json() == {"detail": "Not Found"}
