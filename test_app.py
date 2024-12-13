import pytest
from application import app

@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@pytest.mark.home
def test_home(client):
    """Test the home page."""
    response = client.get('/')
    assert response.status_code == 200

@pytest.mark.auth
@pytest.mark.registration
def test_register(client):
    """Test user registration."""
    response = client.post('/register', data={
        'username': 'testuser',
        'password': 'testpassword',
        'confirm_password': 'testpassword'
    })
    assert b'Your account has been created!' in response.data

@pytest.mark.auth
@pytest.mark.login
def test_login(client):
    """Test user login."""
    # First, register a user
    client.post('/register', data={
        'username': 'testuser',
        'password': 'testpassword',
        'confirm_password': 'testpassword'
    })

    # Now, log in
    response = client.post('/login', data={
        'username': 'testuser',
        'password': 'testpassword'
    })
    assert b'You have logged in successfully!' in response.data
