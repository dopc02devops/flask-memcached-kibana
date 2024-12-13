# Use a lightweight Python image for testing
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy only requirements first for better caching during builds
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project
COPY . /app

# Set the Flask app for testing (in-memory testing, no server started)
ENV FLASK_ENV=testing

# Set the entrypoint to run pytest tests when the container starts
ENTRYPOINT ["pytest", "--maxfail=5", "--disable-warnings", "-v"]
