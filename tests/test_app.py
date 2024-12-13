import pytest
from src.application import MemcachedApp


# Create a fixture to provide the test client
@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app = MemcachedApp().app  # Get the app instance from MemcachedApp
    app.config['TESTING'] = True  # Enable testing mode
    with app.test_client() as client:
        yield client


# Test class for the Flask app
class TestflaskApp:

    @pytest.mark.home
    def test_home(self, client):
        """Test the home page."""
        response = client.get('/')
        assert response.status_code == 200

    @pytest.mark.auth
    @pytest.mark.registration
    def test_register(self, client):
        """Test user registration."""
        response = client.post('/register', data={
            'username': 'testuser',
            'password': 'testpassword',
            'confirm_password': 'testpassword'
        })
        assert b'Your account has been created!' in response.data

    @pytest.mark.auth
    @pytest.mark.login
    def test_login(self, client):
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
