pipeline {
    agent any

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')
    }

    stages {

        stage('Check Docker is running') {
            steps {
                script {
                    sh '''
                    set -e
                    echo "Verifying Docker and dependencies..."

                    # Check if python3 and pip are installed, install if missing
                    if ! command -v python3 > /dev/null; then
                        echo "python3 not found, installing..."
                        sudo apt update
                        sudo apt install python3 -y
                    else
                        echo "python3 is already installed."
                    fi

                    if ! command -v pip3 > /dev/null; then
                        echo "pip3 not found, installing..."
                        sudo apt install python3-pip -y
                    else
                        echo "pip3 is already installed."
                    fi

                    # Verify Docker is installed
                    if ! command -v docker > /dev/null; then
                        echo "Docker is not installed. Please install Docker before running this pipeline."
                        exit 1
                    else
                        echo "Docker is installed. Version:"
                        sudo docker --version
                    fi

                    # Verify docker-compose is installed
                    if ! command -v docker-compose > /dev/null; then
                        echo "docker-compose is not installed. Please install docker-compose before running this pipeline."
                        exit 1
                    else
                        echo "docker-compose is installed. Version:"
                        sudo docker-compose --version
                    fi

                    # Check if Docker daemon is running
                    if ! sudo docker ps > /dev/null 2>&1; then
                        echo "Docker daemon is not running. Please start the Docker service."
                        exit 1
                    else
                        echo "Docker daemon is running."
                    fi
                    '''
                }
            }
        }


        stage('Extract Git Tag') {
            steps {
                script {
                    if (env.GIT_TAG) {
                        currentBuild.displayName = "Build for tag: ${env.GIT_TAG}"
                        echo "Detected Git tag: ${env.GIT_TAG}"
                        params.DOCKER_TAG = env.GIT_TAG
                    } else {
                        echo "No Git tag detected, using specified tag or default (latest)"
                        if (!params.DOCKER_TAG) {
                            params.DOCKER_TAG = 'latest'
                        }
                    }
                }
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Checking out source code..."
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${params.BRANCH}"]],
                        userRemoteConfigs: [[url: 'https://github.com/dopc02devops/flask-memcached-kibana.git']]
                    ])
                }
            }
        }

        stage('Scan Dockerfile with Trivy') {
            steps {
                echo "Scanning Dockerfile with Trivy..."
                script {
                    sh '''
                    set -e
                    # Install Trivy if not already installed
                    if ! command -v trivy > /dev/null; then
                        echo "Installing Trivy..."
                        sudo apt-get update
                        sudo apt-get install -y wget
                        sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.29.1/trivy_0.29.1_Linux-64bit.deb
                        sudo dpkg -i trivy_0.29.1_Linux-64bit.deb
                    fi

                    echo "Scanning Dockerfile..."
                    cd src
                    sudo trivy config --severity HIGH,CRITICAL ./Dockerfile.app || exit 1
                    '''
                }
            }
        }

        stage('Setup and Run Tests') {
            steps {
                echo "Setting up and running tests..."
                script {
                    sh '''
                    set -e
                    sudo docker volume create app_volume
                    pip install pytest-html
                    sudo docker-compose -f docker-compose.test.yml up --build test-app || exit 1

                    mkdir -p reports-xml
                    mkdir -p reports-html
                    sudo docker cp flask-tests-container:/app/report.xml ./report.xml
                    sudo docker cp flask-tests-container:/app/report.html ./report.html
                    '''
                }
            }
        }

        stage('Archive Test Reports') {
            steps {
                echo "Archiving test reports..."
                archiveArtifacts artifacts: 'reports-xml/test_report.xml, reports-html/test_report.html', allowEmptyArchive: false
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${params.DOCKER_TAG}..."
                script {
                    sh '''
                    set -e
                    cd src
                    docker build -t $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG} -f ./Dockerfile.app .
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image: ${params.DOCKER_TAG}..."
                script {
                    sh '''
                    set -e
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    docker push $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG}
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. Cleaning workspace...'
            cleanWs() // Clean workspace after pipeline execution
        }
    }
}
