
# Create virtual env
    install python
    python3 -m venv venv
    source venv/bin/activate
    pip3 install -r src/requirements.txt
    pip3 freeze > src/requirements.txt 
        Only do this if requirements.txt is empty
        First install al dependencies then run pip freeze command

# run application locally
    install docker
    install docker-compose
    cd src
    docker build -t image-name:tag -f ./Dockerfile.app .
        e.g docker build -t dockerelvis/python-memcached:v-24 -f ./Dockerfile.app .
    cd .. to base directory where docker-compose file is located
    run command to start application
        docker volume create flask-app-data
        docker volume create memcached-data
        Edit docker-compose.env and set image: dockerelvis/python-memcached:v-24
        docker-compose -f docker-compose.env.yml up -d
    access app on:  
        http://localhost:8096/login
        http://127.0.0.1:8096/login


# ssh
    ssh -i ~/.ssh/id_kube_user_key jenkins@ip
    copy key: pbcopy < ~/.ssh/id_kube_user_key.pub

# create cluster

# install nfs-server

# install kibana

# access application
- kubectl get svc -n stage
- get the external ip of the service
- go to ur browser and enter
- externalip:port to access application

# host file
sudo vim /Users/name/.ssh/known_hosts

