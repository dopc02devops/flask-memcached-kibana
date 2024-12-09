from flask import Flask, request, render_template, redirect, url_for, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from pymemcache.client import base
from logger import logger
import os
from memcached_docker import *

app = Flask(__name__)

# Simulated database of users (in-memory, for simplicity)
users = {}
OPERATING_SYSTEM = None

OPERATING_SYSTEM = os.getenv('OPERATING_SYSTEM')
MEMCACHED_HOST = os.getenv('MEMCACHED_HOST')
MEMCACHED_PORT = os.getenv('MEMCACHED_PORT')
OPERATING_SYSTEM = "docker"
app.secret_key = "'supersecretkey'"

try:
    if OPERATING_SYSTEM and OPERATING_SYSTEM.lower() == "kubernetes":
        # Connect to Memcached
        memcached_client = base.Client((MEMCACHED_HOST, MEMCACHED_PORT))
        logger().info(f"Successfully connected to {MEMCACHED_HOST}")
        logger().info(f"client info: {memcached_client}")

    elif OPERATING_SYSTEM.lower() == "docker":
        # ps aux | grep memcached
        # kill pid 11211
        # docker pull memcached
        # docker run -d --name memcached -p 11211:11211 memcached
        # docker ps
        kill_memcached()
        pull_memcached_image()
        run_memcached_container()
        list_docker_containers()
        memcached_client = base.Client(('host.docker.internal', 11211))

    else:
        memcached_client = base.Client(('127.0.0.1', 11211))
        logger().info(f"Successfully connected to local memcached")
        logger().info(f"client info: {memcached_client}")

except Exception as e:
    print(f"Error connecting to Memcached: {e}")
    logger().error(f"Error connecting to Memcached: {e}")
    memcached_client = None


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        logger().info(f"Get username form")
        password = request.form.get('password')
        logger().info(f"Get password form")
        confirm_password = request.form.get('confirm_password')
        logger().info(f"Get confirm-password form")

        # Validation
        if username in users:
            flash('Username already exists!')
            logger().info(f"Username already exists!")
        elif password != confirm_password:
            flash('Passwords do not match!')
            logger().info(f"Passwords do not match!")
        else:
            # Hash the password before storing it
            users[username] = generate_password_hash(password)
            flash('Registration successful! You can now log in.')
            logger().info(f"Registration successful! You can now log in.")
            return redirect(url_for('login'))
    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        logger().info(f"Get username and password forms")

        if username in users and check_password_hash(users[username], password):
            session['username'] = username
            flash('You are logged in!')
            logger().info(f"You are logged in!")
            return redirect(url_for('home'))
        else:
            flash('Invalid credentials. Please try again.')
            logger().error(f"Invalid credentials. Please try again.")

    return render_template('login.html')


@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    logger().info(f"Cleared session data")
    return redirect(url_for('login'))


@app.route('/')
def home():
    if 'username' not in session:
        flash('You need to log in first!')
        logger().info(f"You need to log in first!")
        return redirect(url_for('login'))

    return render_template('template.html', username=session['username'])


@app.route('/set', methods=['POST'])
def set_cache():
    if 'username' not in session:
        flash('You need to log in first!')
        logger().info(f"You need to log in first!")
        return redirect(url_for('login'))

    key = request.form.get('key')
    value = request.form.get('value')
    expiry = request.form.get('expiry', '0')
    logger().info(f"Setting key, value and expiry")

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

    if memcached_client:
        memcached_client.set(key, value, expire=expiry if expiry > 0 else None)
        logger().info(f"Set key {key} with value {value}")
        return render_template('template.html', result=f"Set key '{key}' with value '{value}'")
    else:
        logger().error(f"Memcached client not initialized.")
        return render_template('template.html', result="Memcached client not initialized.")


# Get cache route
@app.route('/get', methods=['POST'])
def get_cache():
    if 'username' not in session:
        flash('You need to log in first!')
        logger().info(f"You need to log in first!")
        return redirect(url_for('login'))

    key = request.form.get('key')
    if not key:
        logger().info(f"Key is required.")
        return render_template('template.html', result="Key is required.")

    if memcached_client:
        value = memcached_client.get(key)
        if value:
            logger().info(f"Value for key '{key}': {value.decode('utf-8')}")
            return render_template('template.html', result=f"Value for key '{key}': {value.decode('utf-8')}")
        else:
            logger().info(f"Key '{key}' not found in cache.")
            return render_template('template.html', result=f"Key '{key}' not found in cache.")
    else:
        logger().error(f"Memcached client not initialized.")
        return render_template('template.html', result="Memcached client not initialized.")


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8095, debug=True)
