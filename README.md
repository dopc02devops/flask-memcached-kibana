
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
            # git tag v1.0
            # git push origin v1.0
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


