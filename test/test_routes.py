def test_home_page(client):
    """Test the home page route"""
    response = client.get("/")
    assert response.status_code == 200
    assert b"Welcome to My Webapp" in response.data

def test_404_page(client):
    """Test non-existent route"""
    response = client.get("/nonexistent")
    assert response.status_code == 404