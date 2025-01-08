
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
    Labels: docker-agent/any
    copy key: pbcopy < ~/.ssh/id_kube_user_key

35.197.250.0
# Build
    select pipeline as job type
    

# Agent configuration
    sudo apt update
    sudo apt install openjdk-17-jdk
    snap install docker
    sudo apt update
    sudo apt install -y docker.io

# Verify the installation:
    java -version
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
# add user to docker group
sudo groupadd docker
sudo usermod -aG docker jenkins
groups jenkins

