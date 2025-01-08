
# Installation
    docker-compose -f docker-compose.jenkins.yml up -d
    docker-compose -f docker-compose.jenkins.yml up --build -d (no cache)
    docker-compose -f docker-compose.jenkins.yml down
    http://localhost:8080
    login to container 
        adminpassword: cat /var/jenkins_home/secrets/initialAdminPassword
        user: admin
        password: admin123
        email: dopc02devops@gmail.com
    login and configure node
    Remote root directory: /home/jenkins
    Labels: docker-agent
    copy key: pbcopy < ~/.ssh/id_kube_user_key

# Agent configuration
    sudo apt update
    sudo apt install openjdk-17-jdk
# Verify the installation:
    java -version
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH

    