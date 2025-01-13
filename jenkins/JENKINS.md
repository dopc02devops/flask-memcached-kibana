
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
    Remote root directory: /home/jenkins
    Labels: docker-agent/any
    user: jenkins
    copy key: pbcopy < ~/.ssh/id_kube_user_key
    machine-elastic-ip: 35.197.250.0
    plugins:
        AWS Credentials
    Add aws keys
    Add git keys


# Build
    select pipeline as job type
    

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
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install docker-ce
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker --version

# Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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


# ducker
docker system prune -a (removes all unused images)
docker system prune
docker system prune -a --volumes


host file
sudo vim /Users/elvisngwesse/.ssh/known_hosts

vim /etc/ssh/sshd_config
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
sudo systemctl restart sshd
