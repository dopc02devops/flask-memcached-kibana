pipeline {
    agent {
        label 'docker-agent'  // Specify the label of the remote machine (agent)
        docker {
            image 'ubuntu:latest'  // Use the latest Ubuntu image
            args '-v /tmp:/tmp'    // Optional: Mounting volume (if necessary)
        }
    }

    stages {
        stage('Setup Python') {
            steps {
                echo "Running on a Docker container provisioned by Jenkins"
                script {
                    // Install Python inside the Ubuntu container
                    sh '''
                    apt-get update && \
                    apt-get install -y python3 python3-pip
                    '''
                }
            }
        }
        stage('Build') {
            steps {
                echo "Running npm install (if needed)"
                sh 'npm install'
            }
        }
    }
}
