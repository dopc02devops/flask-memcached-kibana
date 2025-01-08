pipeline {
    agent {
        label 'docker-agent'  // Specify the label of the remote machine (agent)
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')  // Parameter to specify branch
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')  // Default to 'latest'
    }

    environment {
        DOCKER_USERNAME = credentials('docker-username')  // Set up Docker Hub username from Jenkins credentials
        DOCKER_PASSWORD = credentials('docker-password')  // Set up Docker Hub password from Jenkins credentials
    }

    stages {
        stage('Extract Git Tag') {
            steps {
                script {
                    // Check if the build was triggered by a Git tag
                    if (env.GIT_TAG) {
                        // Use the Git tag directly if available
                        currentBuild.displayName = "Build for tag: ${env.GIT_TAG}"
                        echo "Detected Git tag: ${env.GIT_TAG}"
                        // Set the DOCKER_TAG to the Git tag value
                        params.DOCKER_TAG = env.GIT_TAG
                    } else {
                        // If no Git tag, use the parameter or default (latest)
                        echo "No Git tag detected, using specified tag or default (latest)"
                        if (!params.DOCKER_TAG) {
                            params.DOCKER_TAG = 'latest'  // Set default to latest if no tag is provided
                        }
                    }
                }
            }
        }

        stage('Start Docker Daemon') {
            steps {
                echo "Starting Docker Daemon"
                script {
                    sh '''
                    dockerd &  # Start Docker Daemon in the background
                    sleep 5    # Wait for the daemon to initialize
                    docker ps  # Test if Docker is running
                    docker --version
                    docker-compose --version
                    '''
                }
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Checking out source code"
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${params.BRANCH}"]],  // Use the branch parameter for checkout
                        userRemoteConfigs: [[url: 'https://github.com/dopc02devops/flask-memcached-kibana.git']]
                    ])
                }
            }
        }

        stage('Scan Dockerfile with Trivy') {
            steps {
                echo "Scanning Dockerfile with Trivy"
                script {
                    sh '''
                    # Install Trivy if not already installed
                    if ! command -v trivy &>/dev/null; then
                        echo "Trivy not found, installing..."
                        curl -sfL https://github.com/aquasecurity/trivy/releases/download/v0.29.0/trivy_0.29.0_Linux-x86_64.tar.gz | tar -xzv -C /usr/local/bin trivy
                    fi

                    # Scan the Dockerfile with Trivy
                    trivy config --no-progress --severity HIGH,CRITICAL --format table --output reports-xml/dockerfile_scan_report.txt ./Dockerfile.app || exit 1
                    '''
                }
            }
        }

        stage('Setup and Run Tests') {
            steps {
                echo "Setting up Docker environment and running tests"
                script {
                    sh '''
                    # Create necessary directories for reports
                    mkdir -p reports-xml
                    mkdir -p reports-html

                    # Install pytest and plugins
                    pip install pytest pytest-html pytest-xml

                    # Run pytest and generate HTML and XML reports
                    pytest --junitxml=reports-xml/test_report.xml \
                           --html=reports-html/test_report.html --self-contained-html || exit 1

                    # Build and test application using docker-compose
                    docker-compose -f docker-compose.test.yml up --build test-app || exit 1
                    '''
                }
            }
        }

        stage('Archive Test Reports') {
            steps {
                echo "Archiving test reports"
                archiveArtifacts artifacts: 'reports-xml/test_report.xml, reports-html/test_report.html, reports-xml/dockerfile_scan_report.txt', allowEmptyArchive: false
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${params.DOCKER_TAG}"
                script {
                    sh '''
                    set -e
                    cd src  # Change directory to where the Dockerfile is located
                    docker build -t $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG} -f ./Dockerfile.app .  # Build the Docker image with the parameterized tag
                    '''
                }
            }
        }


        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image: ${params.DOCKER_TAG}"
                script {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin  # Login to Docker Hub
                    docker push $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG}  # Push the image to Docker Hub
                    '''
                }
            }
        }
    }
}
