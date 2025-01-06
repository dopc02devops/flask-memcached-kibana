
# Create virtual env
    # install python
    # python3 -m venv venv
    # source venv/bin/activate
    # pip3 install -r src/requirements.txt
    # pip3 freeze > src/requirements.txt 
        # Only do this if requirements.txt is empty
        # First install al dependencies then run pip freeze command

# run application locally
    # install docker
    # install docker-compose
    # cd src
    # docker build -t image-name:tag -f ./Dockerfile.app .
        # e.g docker build -t flask-image:v-22 -f ./Dockerfile.app .
    # cd .. to base directory where docker-compose file is located
    # run command to start application
        # docker volume create flask-app-data
        # docker volume create memcached-data
        # Edit docker-compose.env and set image: flask-image:v-22
        # docker-compose -f docker-compose.env.yml up -d

# Copy ssh keys
    # pbcopy < ~/.ssh/id_kube_user_key.pub
    # pbcopy < ~/.ssh/id_kube_user_key

# Circleci pipeline
    # push to main will trigger the below pipelines
        # - install_dependencies
        # - scan_docker_file
        # - test
        # - build_docker_image
    # push to main with tag will trigger the below pipelines
        # - build_docker_image_tag
        # - deploy_test_env
            # git tag version-1.0
            # git push origin version-1.0
    # push to main with release tag will trigger the below pipelines
        # - build_docker_image_tag
        # - deploy_test_env
            # git tag release-1.0
            # git push origin release-1.0

# git commands
      git checkout -b ur-branch
      git checkout ur-branch
      git commit --allow-empty -m "Trigger build"
      git push origin ur-branch


# create cluster
# e2 small
gcloud container clusters create my-cluster \
--num-nodes=2 \
--region europe-west2-a \
--release-channel "stable" \
--disk-type=pd-standard \
--machine-type "e2-small" \
--enable-ip-alias
# e2-medium
gcloud container clusters create my-cluster \
--num-nodes=2 \
--region europe-west2-a \
--release-channel "stable" \
--disk-type=pd-standard \
--machine-type "e2-medium" \
--enable-ip-alias


# list firewalls
- gcloud compute firewall-rules list

# get machines
- gcloud compute instances list --zones europe-west2-a

# get machine tags
- gcloud compute instances describe <node-name> --format="get(tags.items)"

# tag machine
gcloud compute instances add-tags <node-name> --tags gke-my-cluster

# open firewall
gcloud compute firewall-rules create allow-ssh-and-custom-ports \
--allow tcp:22,tcp:8096,tcp:8091,tcp:8095 \
--target-tags gke-my-cluster \
--description "Allow SSH and custom ports access to GKE nodes" \
--direction INGRESS \
--priority 1000

# get credentials
gcloud container clusters get-credentials my-cluster --region europe-west2-a

# describe machine
gcloud compute instances describe my-vm --zone europe-west2-a --project superb-gear-443409-t3

# login to cluster
- go to cluster and copy connect command
- gcloud container clusters get-credentials my-cluster --zone europe-west2-a --project superb-gear-443409-t3

# Trigger cirleci pipeline
- git tag release-1.0
- git push origin release-1.0


# commands for debugging
- kubectl get pods -n stage
- kubectl get pod <pod-name> -n stage
- kubectl logs <pod-name> -n stage
- kubectl get pvc -n stage
- kubectl describe pod <pod-name> -n stage
- kubectl get events -n stage
- kubectl describe deployment flask-app-deployment -n stage

# access application
- kubectl get svc -n stage
- get the external ip of the service
- go to ur browser and enter
- externalip:port to access application

