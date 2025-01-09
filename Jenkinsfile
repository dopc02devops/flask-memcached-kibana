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
                    sudo docker ps
                    sudo docker --version
                    sudo docker-compose --version
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
                        env.DOCKER_TAG = env.GIT_TAG
                    } else {
                        echo "No Git tag detected, using specified tag or default (latest)"
                        if (!env.DOCKER_TAG) {
                            env.DOCKER_TAG = 'latest'
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
                    mkdir -p reports-xml reports-html

                    pip install --user pytest pytest-html

                    export PATH=$HOME/.local/bin:$PATH

                    pytest --junitxml=reports-xml/report.xml --html=reports-html/report.html --self-contained-html || echo "Tests failed but proceeding with the pipeline"
                    '''
                }
            }
        }

        stage('Store Test Reports') {
            steps {
                echo "Storing test reports..."
                archiveArtifacts artifacts: 'reports-xml/report.xml', allowEmptyArchive: true
                archiveArtifacts artifacts: 'reports-html/report.html', allowEmptyArchive: true
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.DOCKER_TAG}..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                        set -e
                        cd src
                        echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                        docker build -t \$DOCKER_USERNAME/python-memcached:${env.DOCKER_TAG} -f ./Dockerfile.app .
                        docker push \$DOCKER_USERNAME/python-memcached:${env.DOCKER_TAG}
                        docker logout
                        """
                    }
                }
            }
        }

        stage('Setup Docker Volumes and Start Services') {
            steps {
                echo "Creating Docker volumes and starting services..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                        set -e
                        sudo docker volume create flask-app-data || true
                        sudo docker volume create memcached-data || true
                        sudo VERSION=${env.DOCKER_TAG} docker-compose -f docker-compose.env.yml up -d
                        docker logout
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed. Cleaning workspace...'
            cleanWs()
        }
    }
}
