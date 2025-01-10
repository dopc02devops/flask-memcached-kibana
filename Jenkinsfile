pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        CLUSTER_NAME = 'your-eks-cluster-name'
        DOCKER_BUILDKIT = '1' // Enable BuildKit for this pipeline
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')
    }

    stages {
        stage('Install buildx') {
            steps {
                echo "Installing buildx..."
                script {
                    sh '''
                    # Ensure Docker is installed and running
                    sudo apt-get update
                    sudo apt-get install -y curl

                    # Download and install buildx component
                    mkdir -p ~/.docker/cli-plugins
                    curl -LO https://github.com/docker/buildx/releases/download/v0.8.0/buildx-v0.8.0.linux-amd64
                    chmod +x buildx-v0.8.0.linux-amd64
                    mv buildx-v0.8.0.linux-amd64 ~/.docker/cli-plugins/buildx

                    # Check if buildx is properly installed
                    docker buildx version
                    '''
                }
            }
        }

        stage('Check Docker is Running') {
            steps {
                script {
                    sh '''
                    set -e
                    # Check Docker installation
                    if ! command -v docker &> /dev/null
                    then
                        echo "Docker is not installed!"
                        exit 1
                    fi

                    sudo docker ps
                    sudo docker --version
                    sudo docker-compose --version
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        withEnv(["DOCKER_TAG=${env.DOCKER_TAG}"]) {
                            // Check files in the workspace
                            sh '''
                            echo "Listing files in the workspace:"
                            ls -la
                            '''

                            // Use buildx to build the Docker image with BuildKit
                            sh '''
                            set -e
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            if [ $? -ne 0 ]; then
                                echo "Docker login failed!"
                                exit 1
                            fi

                            docker buildx create --use
                            docker buildx build -t $DOCKER_USERNAME/python-memcached:$DOCKER_TAG -f ./src/Dockerfile.app --push .
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
                            export VERSION=${VERSION}  # Ensure VERSION is exported as an environment variable

                            # Create Docker volumes if they don't exist
                            if ! docker volume ls -q -f name=flask-app-data; then
                                sudo docker volume create flask-app-data
                            fi
                            if ! docker volume ls -q -f name=memcached-data; then
                                sudo docker volume create memcached-data
                            fi

                            # Pass VERSION explicitly in the docker-compose command
                            VERSION=${VERSION} sudo docker-compose -f docker-compose.env.yml up -d --remove-orphans
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
