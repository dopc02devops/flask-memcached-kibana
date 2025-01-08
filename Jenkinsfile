pipeline {
    agent {
        label 'docker-agent'
    }

    parameters {
        string(name: 'BRANCH', defaultValue: 'main', description: 'Branch to build from')
        string(name: 'DOCKER_TAG', defaultValue: 'latest', description: 'Docker image tag (defaults to latest if not provided)')
    }

    stages {
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

        stage('Start Docker Daemon') {
            steps {
                echo "Checking Docker status"
                script {
                    sh '''
                    docker ps  # Test if Docker is running
                    docker --version  # Check Docker version
                    docker-compose --version  # Check docker-compose version
                    '''
                }
            }
        }

        // Uncomment and complete the remaining stages as needed
        // stage('Checkout Code') {
        //     steps {
        //         echo "Checking out source code"
        //         script {
        //             checkout([
        //                 $class: 'GitSCM',
        //                 branches: [[name: "*/${params.BRANCH}"]],
        //                 userRemoteConfigs: [[url: 'https://github.com/dopc02devops/flask-memcached-kibana.git']]
        //             ])
        //         }
        //     }
        // }

        // stage('Scan Dockerfile with Trivy') {
        //     steps {
        //         echo "Scanning Dockerfile with Trivy"
        //         script {
        //             sh '''
        //             if ! command -v trivy &>/dev/null; then
        //                 echo "Trivy not found, installing..."
        //                 curl -sfL https://github.com/aquasecurity/trivy/releases/download/v0.29.0/trivy_0.29.0_Linux-x86_64.tar.gz | tar -xzv -C /usr/local/bin trivy
        //             fi
        //             trivy config --no-progress --severity HIGH,CRITICAL --format table --output reports-xml/dockerfile_scan_report.txt ./Dockerfile.app || exit 1
        //             '''
        //         }
        //     }
        // }

        // stage('Setup and Run Tests') {
        //     steps {
        //         echo "Setting up Docker environment and running tests"
        //         script {
        //             sh '''
        //             mkdir -p reports-xml reports-html
        //             pip install pytest pytest-html pytest-xml
        //             pytest --junitxml=reports-xml/test_report.xml --html=reports-html/test_report.html --self-contained-html || exit 1
        //             docker-compose -f docker-compose.test.yml up --build test-app || exit 1
        //             '''
        //         }
        //     }
        // }

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
