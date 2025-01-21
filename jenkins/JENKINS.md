
# Start Jenkins
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
        make sure u have a machine
        Number of executors: 10
        Remote root directory: /home/jenkins
        Labels: docker-agent/any
        Lunch method: ssh
        host: machine-elastic-ip 35.197.250.0
        Add credentials:
            ssh username with private key:
                id: ssh_user_jenkins
                username: jenkins
                private key: pbcopy < ~/.ssh/id_kube_user_key
        Non verifying verification strategy
    Add plugins:
        AWS Credentials
    Add credentials
        Add docker login
            id: docker-credentials-id
            username: xxxxx
            password: yyyyy
        Add aws login
            id: aws-credentials-id
        Add git login
            id: github-credentials-id
            username: xxxxx
            password: yyyyy
    

# Agent configuration
    sudo apt update
    sudo apt install openjdk-17-jdk
    sudo apt install -y docker.io
    sudo apt install python3 -y
    sudo apt-get install unzip

    # install docker
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -        cs) stable"
        sudo apt update
        sudo apt install docker-ce
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo docker --version

    # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -        s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        docker-compose --version

    # Verify the installation:
        java -version
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        export PATH=$JAVA_HOME/bin:$PATH

    # add user to docker group
        sudo groupadd docker
        sudo usermod -aG docker jenkins
        groups jenkins

# Build
    select pipeline as job type

# tag and push
git add .
git commit --allow-empty -m "empty"
git commit -m "updated jenkins file"
git tag v1.0.0
git push origin main
git push origin v1.0.0

# ducker
docker system prune -a (removes all unused images)
docker system prune
docker system prune -a --volumes
