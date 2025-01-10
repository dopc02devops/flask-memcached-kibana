pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        CLUSTER_NAME = 'your-eks-cluster-name'
//         DOCKER_BUILDKIT = "1"  // Enable BuildKit for this pipeline
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')
    }

    stages {
        stage('Check Docker is Running') {
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

        stage('Build and Push Docker Image') {
            steps {
                echo "Building Docker image..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        withEnv(["DOCKER_TAG=${env.DOCKER_TAG}"]) {
                            sh '''
                            set -e
                            cd src
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker build -t $DOCKER_USERNAME/python-memcached:$DOCKER_TAG -f ./Dockerfile.app .
                            docker push $DOCKER_USERNAME/python-memcached:$DOCKER_TAG
                            docker logout
                            '''
                        }
                    }
                }
            }
        }

        stage('Setup Docker Volumes and Start Services') {
            steps {
                echo "Creating Docker volumes and starting services..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        withEnv(["VERSION=${env.DOCKER_TAG}"]) {
                            sh '''
                            set -e
                            export VERSION=${VERSION}
                            sudo docker volume create flask-app-data || true
                            sudo docker volume create memcached-data || true
                            sudo docker-compose -f docker-compose.env.yml up -d --remove-orphans
                            '''
                        }
                    }
                }
            }
        }

        stage('Install AWS CLI and Kubectl') {
            steps {
                sh '''
                # Install AWS CLI
                curl "https://awscli.amazonaws.com/aws-cli-v2-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install

                # Install kubectl
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
                '''
            }
        }

        stage('Authenticate with EKS') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials-id']]) {
                        sh '''
                        # Configure AWS CLI
                        aws configure set region $AWS_REGION

                        # Retrieve the EKS cluster credentials
                        aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                        '''
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
