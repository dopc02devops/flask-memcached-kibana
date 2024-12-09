

############################
Install
############################
- pip install flask pymemcache
- brew install  memcached
- start service
- memcached -d -m 64 -p 11211 -u memcache


############################
Build the Docker Image
############################
- docker build -t python-memcached-app .  
- docker build --no-cache -t python-memcached-app .
- docker run -it --rm --name python-memcached-container -p 8090:8088 python-memcached-app
- docker run -it --rm --name python-memcached-container python-memcached-app
- docker run -it --rm -p 8095:8095 -e HOST=0.0.0.0 -e PORT=8095 --name python-memcached-container python-memcached-app
- docker run -it --rm -p 8095:8095 --name python-memcached-container python-memcached-app

Explanation:
-it: Runs the container in interactive mode.
--rm: Automatically removes the container after it stops.
--name python-memcached-container: Names the container python-k8s-container.
python-memcached-app: Specifies the image to run.
-p 8090:8088: Maps port 8000 inside the container to port 8080 on the host.
8090: The port you’ll use to access the app on your host.
8088: The port your application is listening to inside the container.


Trouble shooting
- docker ps
- docker inspect f0a4e7e8ac76e0e6044240c8140106962c359a49571ec3879469050b968b45dd | grep "IPAddress"
- docker inspect f0a4e7e8ac76e0e6044240c8140106962c359a49571ec3879469050b968b45dd | grep "NetworkMode"
-  docker logs f0a4e7e8ac76e0e6044240c8140106962c359a49571ec3879469050b968b45dd# flask-memcached
