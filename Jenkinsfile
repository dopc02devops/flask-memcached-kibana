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
                    sh '''
                    set -e
                    if ! sudo docker ps > /dev/null 2>&1; then
                        echo "Docker is not running. Please start Docker."
                        exit 1
                    fi
                    echo "Docker version:"
                    sudo docker --version
                    echo "Docker Compose version:"
                    sudo docker-compose --version
                    '''
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
                        userRemoteConfigs: [[
                            url: env.GIT_REPO_URL,
                            credentialsId: 'github-credentials-id'
                        ]]
                    ])
                }
            }
        }

        stage('Extract Git Tag') {
            steps {
                echo "Extracting git tag..."
                script {
                    def gitTag = sh(script: 'git describe --tags --exact-match || echo ""', returnStdout: true).trim()
                    if (gitTag) {
                        currentBuild.displayName = "Build for tag: ${gitTag}"
                        echo "Detected Git tag: ${gitTag}"
                        env.DOCKER_TAG = gitTag
                    } else {
                        echo "No Git tag detected. Using default tag: ${params.DOCKER_TAG}"
                        env.DOCKER_TAG = params.DOCKER_TAG
                    }
                }
            }
        }

        stage('Scan Dockerfile with Trivy') {
            steps {
                echo "Scanning Dockerfile for vulnerabilities..."
                script {
                    sh '''
                    set -e
                    if ! command -v trivy > /dev/null; then
                        echo "Trivy not found. Installing Trivy..."
                        sudo apt-get update
                        sudo apt-get install -y wget
                        wget https://github.com/aquasecurity/trivy/releases/download/v0.29.1/trivy_0.29.1_Linux-64bit.deb
                        sudo dpkg -i trivy_0.29.1_Linux-64bit.deb
                    fi

                    echo "Running Trivy scan on Dockerfile..."
                    cd src
                    trivy config --severity HIGH,CRITICAL ./Dockerfile.app
                    '''
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
                expression { return env.DOCKER_TAG != null && env.DOCKER_TAG != '' }
            }
            steps {
                echo "Building and pushing Docker image..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        set -e
                        cd src
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                        docker build -t $DOCKER_USERNAME/python-memcached:${DOCKER_TAG} -f ./Dockerfile.app .
                        docker push $DOCKER_USERNAME/python-memcached:${DOCKER_TAG}
                        docker logout
                        '''
                    }
                }
            }
        }

        stage('Setup Docker Volumes and Start Services') {
            when {
                expression { return env.DOCKER_TAG != null && env.DOCKER_TAG != '' }
            }
            steps {
                echo "Setting up Docker volumes and starting services..."
                script {
                    sh '''
                    set -e
                    sudo docker volume create flask-app-data || true
                    sudo docker volume create memcached-data || true
                    sudo VERSION=${DOCKER_TAG} docker-compose -f docker-compose.env.yml down --remove-orphans
                    sudo VERSION=${DOCKER_TAG} docker-compose -f docker-compose.env.yml up -d
                    '''
                }
            }
        }

        stage('Install AWS CLI, Kubectl, and Helm') {
            when {
                expression { return env.DOCKER_TAG != null && env.DOCKER_TAG != '' }
            }
            steps {
                echo "Installing or updating AWS CLI v2, kubectl, and Helm..."
                script {
                    sh '''
                    set -e

                    TMP_DIR=$(mktemp -d)
                    cd $TMP_DIR

                    # Install/Update AWS CLI v2
                    echo "Installing or updating AWS CLI v2..."
                    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                    unzip -o awscliv2.zip
                    sudo ./aws/install --update

                    # Verify AWS CLI installation
                    aws --version || { echo "AWS CLI installation failed"; exit 1; }

                    # Install kubectl
                    echo "Installing kubectl..."
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    sudo mv kubectl /usr/local/bin/

                    # Verify kubectl installation
                    kubectl version --client || { echo "kubectl installation failed"; exit 1; }

                    # Install Helm
                    echo "Installing Helm..."
                    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

                    # Verify Helm installation
                    helm version || { echo "Helm installation failed"; exit 1; }

                    # Clean up temporary directory
                    cd -
                    rm -rf $TMP_DIR
                    '''
                }
            }
        }


        stage('Deploy Helm Chart') {
            when {
                expression { return params.DEPLOY_MANUALLY == true && env.DOCKER_TAG != null && env.DOCKER_TAG != '' }
            }
            steps {
                echo "Authenticating with EKS and deploying Helm chart..."
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        sh '''
                        aws configure set region ${AWS_REGION}
                        aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}
                        kubectl get namespace stage || kubectl create namespace stage

                        helm repo add flask-repo https://dopc02devops.github.io/helms_artifacts/
                        helm repo update
                        helm install flask-app flask-repo/flask-memcached-chart --set container.image.image_tag=${DOCKER_TAG} -n stage
                        kubectl rollout status deployment/flask-app-deployment -n stage --timeout=5m
                        kubectl get pods -n stage
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
