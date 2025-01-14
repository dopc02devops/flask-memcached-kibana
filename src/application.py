from flask import Flask, request, render_template, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from logger_flask import logger
import os
from connection import ConnectionManager


class MemcachedApp(ConnectionManager):
    def __init__(self):

        self.app = Flask(__name__)

        # Initialize class variables
        self.users = {}
        self.OPERATING_SYSTEM = os.getenv('OPERATING_SYSTEM')
        self.MEMCACHED_HOST = os.getenv('MEMCACHED_HOST')
        self.MEMCACHED_PORT = os.getenv('MEMCACHED_PORT')

        # Flask settings
        self.app.secret_key = "'supersecretkey'"

        self.memcached_client = None

        self.initialize_connections()

        # Register routes
        self.setup_routes()

    def initialize_connections(self):

        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "docker":
                self.memcached_client = ConnectionManager().connect_to_docker_memcached()
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "docker-compose":
                self.memcached_client = ConnectionManager().connect_to_docker_compose_memcached()
        if self.OPERATING_SYSTEM is not None:
            if self.OPERATING_SYSTEM == "kubernetes":
                self.memcached_client = ConnectionManager().connect_to_kubernetes_memcached()
        else:
            self.memcached_client = ConnectionManager().connect_to_localhost_memcached()

    def setup_routes(self):
        self.app.add_url_rule('/register', 'register', self.register, methods=['GET', 'POST'])
        self.app.add_url_rule('/login', 'login', self.login, methods=['GET', 'POST'])
        self.app.add_url_rule('/logout', 'logout', self.logout, methods=['POST'])
        self.app.add_url_rule('/', 'home', self.home)
        self.app.add_url_rule('/set', 'set_cache', self.set_cache, methods=['POST'])
        self.app.add_url_rule('/get', 'get_cache', self.get_cache, methods=['POST'])

    def register(self):
        if request.method == 'POST':
            username = request.form.get('username')
            password = request.form.get('password')
            confirm_password = request.form.get('confirm_password')

            # Validation
            if username in self.users:
                flash('Username already exists!')
                logger().info(f"Username already exists!")
            elif password != confirm_password:
                flash('Passwords do not match!')
                logger().info(f"Passwords do not match!")
            else:
                # Hash the password before storing it
                self.users[username] = generate_password_hash(password)
                flash('Registration successful! You can now log in.')
                logger().info(f"Registration successful! You can now log in.")
                return redirect(url_for('login'))
        return render_template('register.html')

    def login(self):
        if request.method == 'POST':
            username = request.form.get('username')
            password = request.form.get('password')

            if username in self.users and check_password_hash(self.users[username], password):
                session['username'] = username
                flash('You are logged in!')
                logger().info(f"You are logged in!")
                return redirect(url_for('home'))
            else:
                flash('Invalid credentials. Please try again.')
                logger().error(f"Invalid credentials. Please try again.")

        return render_template('login.html')

    def logout(self):
        session.clear()
        logger().info(f"Cleared session data")
        return redirect(url_for('login'))

    def home(self):
        if 'username' not in session:
            flash('You need to log in first!')
            logger().info(f"You need to log in first!")
            return redirect(url_for('login'))

        return render_template('template.html', username=session['username'])

    def set_cache(self):
        if 'username' not in session:
            flash('You need to log in first!')
            logger().info(f"You need to log in first!")
            return redirect(url_for('login'))

        key = request.form.get('key')
        value = request.form.get('value')
        expiry = request.form.get('expiry', '0')

        if not key or not value:
            logger().info(f"Key and value are required.")
            return render_template('template.html', result="Key and value are required.")

        try:
            expiry = int(expiry)
            if expiry < 0:
                logger().info(f"Expiry must be non-negative.")
                return render_template('template.html', result="Expiry must be non-negative.")
        except ValueError:
            logger().error(f"Invalid expiry value.")
            return render_template('template.html', result="Invalid expiry value.")

        if self.memcached_client:
            self.memcached_client.set(key, value, expire=expiry if expiry > 0 else None)
            logger().info(f"Set key {key} with value {value}")
            return render_template('template.html', result=f"Set key '{key}' with value '{value}'")
        else:
            logger().error(f"Memcached client not initialized.")
            return render_template('template.html', result="Memcached client not initialized.")

    def get_cache(self):
        if 'username' not in session:
            flash('You need to log in first!')
            logger().info(f"You need to log in first!")
            return redirect(url_for('login'))

        key = request.form.get('key')
        if not key:
            logger().info(f"Key is required.")
            return render_template('template.html', result="Key is required.")

        if self.memcached_client:
            value = self.memcached_client.get(key)
            if value:
                logger().info(f"Value for key '{key}': {value.decode('utf-8')}")
                return render_template('template.html', result=f"Value for key '{key}': {value.decode('utf-8')}")
            else:
                logger().info(f"Key '{key}' not found in cache.")
                return render_template('template.html', result=f"Key '{key}' not found in cache.")
        else:
            logger().error(f"Memcached client not initialized.")
            return render_template('template.html', result="Memcached client not initialized.")

    def run(self):
        self.app.run(host='0.0.0.0', port=8095, debug=True)


if __name__ == '__main__':
    app_instance = MemcachedApp()
    app_instance.run()
