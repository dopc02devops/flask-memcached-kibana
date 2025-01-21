pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-west-2'
        CLUSTER_NAME = 'my-cluster'
        GIT_REPO_URL = 'https://github.com/dopc02devops/flask-memcached-kibana.git'
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')
        booleanParam(name: 'DEPLOY_MANUALLY', defaultValue: false, description: 'Trigger deployment manually')
    }

    stages {
        stage('Check Docker is Running') {
            steps {
                echo "Checking Docker and Docker Compose versions..."
                script {
                    try {
                        sh '''
                        set -e
                        if ! sudo docker ps > /dev/null 2>&1; then
                            echo "ERROR: Docker is not running. Please start Docker."
                            exit 1
                        fi
                        echo "Docker version:"
                        sudo docker --version
                        echo "Docker Compose version:"
                        sudo docker-compose --version
                        '''
                    } catch (Exception e) {
                        error("Docker or Docker Compose is not running or not installed: ${e.message}")
                    }
                }
            }
        }

        stage('Checkout Code') {
            steps {
                echo "Checking out source code from branch: ${params.BRANCH}..."
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${params.BRANCH}"]],
                        userRemoteConfigs: [[
                            url: "${GIT_REPO_URL}",
                            credentialsId: 'github-credentials-id'
                        ]]
                    ])
                }
            }
        }

        stage('Extract Git Tag') {
            steps {
                echo "Extracting Git tag..."
                script {
                    try {
                        sh '''
                        if git describe --tags --exact-match 2>/dev/null; then
                            export GIT_TAG=$(git describe --tags)
                            echo "Detected Git tag: $GIT_TAG"
                        else
                            echo "No Git tag detected."
                        fi
                        '''
                    } catch (Exception e) {
                        echo "Warning: Could not extract Git tag: ${e.message}"
                    }
                }
            }
        }

        stage('Scan Dockerfile with Trivy') {
            steps {
                echo "Scanning Dockerfile for vulnerabilities..."
                script {
                    try {
                        sh '''
                        set -e
                        if ! command -v trivy > /dev/null; then
                            echo "Trivy not found. Installing Trivy..."
                            sudo apt-get update
                            sudo apt-get install -y wget
                            sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.29.1/trivy_0.29.1_Linux-64bit.deb
                            sudo dpkg -i trivy_0.29.1_Linux-64bit.deb
                        fi
                        echo "Running Trivy scan on Dockerfile..."
                        cd src
                        sudo trivy config --severity HIGH,CRITICAL ./Dockerfile.app || echo "Trivy scan completed with findings."
                        '''
                    } catch (Exception e) {
                        echo "Warning: Trivy scan failed: ${e.message}"
                    }
                }
            }
        }

        stage('Setup and Run Tests') {
            steps {
                echo "Setting up environment and running tests..."
                script {
                    sh '''
                    set -e
                    mkdir -p reports-xml reports-html

                    pip install --user pytest pytest-html
                    export PATH=$HOME/.local/bin:$PATH

                    pytest --junitxml=reports-xml/report.xml --html=reports-html/report.html --self-contained-html || echo "Tests completed with errors, continuing..."
                    '''
                }
            }
        }

        stage('Store Test Reports') {
            steps {
                echo "Archiving test reports..."
                archiveArtifacts artifacts: 'reports-xml/report.xml', allowEmptyArchive: true
                archiveArtifacts artifacts: 'reports-html/report.html', allowEmptyArchive: true
            }
        }

        stage('Build and Push Docker Image') {
            when {
                expression { return params.DOCKER_TAG != '' }
            }
            steps {
                echo "Building and pushing Docker image with tag: ${params.DOCKER_TAG}..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        set -e
                        cd src
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker build -t $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG} -f ./Dockerfile.app .
                        docker push $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG}
                        docker logout
                        '''
                    }
                }
            }
        }

        stage('Setup Docker Volumes and Start Services') {
            when {
                expression { return params.DOCKER_TAG != '' }
            }
            steps {
                echo "Setting up Docker volumes and starting services..."
                script {
                    sh '''
                    set -e
                    sudo docker volume create flask-app-data || true
                    sudo docker volume create memcached-data || true
                    sudo VERSION=${params.DOCKER_TAG} docker-compose -f docker-compose.env.yml down --remove-orphans
                    sudo VERSION=${params.DOCKER_TAG} docker-compose -f docker-compose.env.yml up -d
                    '''
                }
            }
        }

        stage('Install AWS CLI and Kubectl') {
            when {
                expression { return params.DOCKER_TAG != '' }
            }
            steps {
                echo "Installing or updating AWS CLI v2 and kubectl..."
                script {
                    sh '''
                    set -e
                    TMP_DIR=$(mktemp -d)
                    cd $TMP_DIR

                    # Install/Update AWS CLI v2
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    sudo ./aws/install --update

                    aws --version || { echo "ERROR: AWS CLI installation failed"; exit 1; }

                    # Install kubectl
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    sudo mv kubectl /usr/local/bin/
                    kubectl version --client || { echo "ERROR: kubectl installation failed"; exit 1; }

                    cd -
                    rm -rf $TMP_DIR
                    '''
                }
            }
        }

        stage('Deploy Helm Chart') {
            when {
                expression { return params.DEPLOY_MANUALLY && params.DOCKER_TAG != '' }
            }
            steps {
                echo "Deploying Helm chart to Kubernetes..."
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        sh '''
                        set -e
                        aws configure set region $AWS_REGION
                        aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                        kubectl get namespace stage || kubectl create namespace stage
                        helm install flask-app flask-repo/flask-memcached-chart --set container.image.image_tag=${params.DOCKER_TAG} -n stage
                        kubectl rollout status deployment/flask-app -n stage --timeout=5m
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed. Cleaning workspace..."
            cleanWs()
        }
    }
}
