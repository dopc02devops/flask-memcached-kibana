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
                        sudo docker ps  # Test if Docker is running
                        sudo docker --version  # Check Docker version
                        sudo docker-compose --version  # Check docker-compose version
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
                    echo "Checking out source code"
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
                    echo "Scanning Dockerfile with Trivy"
                    script {
                        sh '''
                        # Install Trivy if not already installed
                        if ! command -v trivy > /dev/null; then
                            sudo apt-get update
                            sudo apt-get install -y wget
                            sudo wget https://github.com/aquasecurity/trivy/releases/download/v0.29.1/trivy_0.29.1_Linux-64bit.deb
                            sudo dpkg -i trivy_0.29.1_Linux-64bit.deb
                        fi
                        cd src
                        sudo trivy config --severity HIGH,CRITICAL ./Dockerfile.app || exit 1
                        '''
                    }
                }
            }


        stage('Setup and Run Tests') {
            steps {
                echo "Running tests"
                script {
                    sh '''
                    mkdir -p reports-xml reports-html
                    pip install pytest pytest-html pytest-xml
                    pytest --junitxml=reports-xml/test_report.xml --html=reports-html/test_report.html --self-contained-html || exit 1
                    sudo docker-compose -f docker-compose.test.yml up --build test-app || exit 1
                    '''
                }
            }
        }

        // stage('Archive Test Reports') {
        //     steps {
        //         echo "Archiving test reports"
        //         archiveArtifacts artifacts: 'reports-xml/test_report.xml, reports-html/test_report.html, reports-xml/dockerfile_scan_report.txt', allowEmptyArchive: false
        //     }
        // }

        // stage('Build Docker Image') {
        //     steps {
        //         echo "Building Docker image: ${params.DOCKER_TAG}"
        //         script {
        //             sh '''
        //             set -e
        //             cd src
        //             docker build -t $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG} -f ./Dockerfile.app .
        //             '''
        //         }
        //     }
        // }

        // stage('Push Docker Image') {
        //     steps {
        //         echo "Pushing Docker image: ${params.DOCKER_TAG}"
        //         script {
        //             sh '''
        //             echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
        //             docker push $DOCKER_USERNAME/python-memcached:${params.DOCKER_TAG}
        //             '''
        //         }
        //     }
        // }
    }
}
