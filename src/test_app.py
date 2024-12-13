import pytest
import time
import requests
from requests.exceptions import ConnectionError


class TestflaskApp:

    flask_url_home = "http://flask-app:8095/"
    flask_url_register = "http://flask-app:8095/register"
    flask_url_login = "http://flask-app:8095/login"

    def wait_for_flask_app(self, url, retries=2, delay=3):
        for attempt in range(1, retries + 1):
            try:
                response = requests.get(url)
                # If the response is successful (status code 200)
                if response.status_code == 200:
                    print(f"Flask app is available at {url}!")
                    return True
                else:
                    print(f"Received non-200 status code: {response.status_code}")
            except ConnectionError as ex:
                print(f"Attempt {attempt}/{retries} failed: {ex}")
                time.sleep(delay)
            except Exception as ex:
                print(f"Unexpected error: {ex}")
                time.sleep(delay)

        print(f"Flask app not available at {url} after {retries} attempts.")
        return False
    @pytest.mark.home
    def test_home(self):
        assert self.wait_for_flask_app(self.flask_url_home), "failed"
        """Test the home page."""
        response = requests.get(self.flask_url_home)
        assert response.status_code == 200

    @pytest.mark.auth
    @pytest.mark.registration
    def test_register(self):
        assert self.wait_for_flask_app(self.flask_url_register), "faled"
        session = requests.Session()
        response = session.post(self.flask_url_register, data={
            'username': 'testuser',
            'password': 'testpassword',
            'confirm_password': 'testpassword'
        }, allow_redirects=True)
        assert response.status_code == 200
        assert b'Register here' in response.content

    @pytest.mark.auth
    @pytest.mark.login
    def test_login(self):
        assert self.wait_for_flask_app(self.flask_url_register), "failed"
        session = requests.Session()
        session.post(self.flask_url_register, data={
            'username': 'testuser',
            'password': 'testpassword',
            'confirm_password': 'testpassword'
        }, allow_redirects=True)

        response = session.post(self.flask_url_login, data={
            'username': 'testuser',
            'password': 'testpassword'
        }, allow_redirects=True)
        assert response.status_code == 200
        assert b'Memcached Key-Value Store' in response.content
