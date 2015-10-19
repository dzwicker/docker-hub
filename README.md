
# docker-hub

*Easy jetbrains hub deployment using docker*

These Dockerfiles allow you to easily build images to deploy your own [hub](http://www.jetbrains.com/hub/) instance.

## Disclaimer
Besides that, as always, use these scripts with care.

Don't forget to back up your data very often, too.

## Requirements
Docker has to run. It supports many platforms like Ubuntu, Arch Linux, Mac OS X, Windows, EC2 or the Google Cloud.
[Click here](http://docs.docker.io/en/latest/installation/) to get specific infos on how to install on your platform.

## Oh nice! How do I do it?
1. Install docker. [It's not very hard.](http://docs.docker.io/en/latest/installation/)
2. Run it! (Stop with CTRL-C, repeat at pleasure)

  `docker run -t -i -p 127.0.0.1:8080:8080 dzwicker/docker-hub`



Now open your browser and point it to `http://localhost:8080` and rejoice. :)

## Do it as service in ubuntu/debian
1. Create directory to store data
  
  `mkdir -p /var/lib/hub`

2. Permissions!

  The Dockerfile creates a `hub` user to run hub without root permissions. This user has a `UID` of `2000`. Please make sure to add a user to your host system with this `UID` and allow him to read and write to `/var/lib/hub`. The name of this host user in not important. (You can use a the user group, too. It has the `GID` of 2000 :)
  
3. Create container!

  ```
  docker create -t -i -p 127.0.0.1:8080:8080 \ 
  	-v /var/lib/hub:/var/lib/hub \ 
  	-v /var/log/hub:/var/log/hub \
  	-v /etc/hub:/usr/local/hub/conf \
  	-v /tmp:/tmp \
  	--name docker-hub \
  	dzwicker/docker-hub
  ```

4. Create upstart configuration `/etc/init/docker-hub.conf`

	``` bash
	description "Docker Hub"
	start on filesystem and started docker
	stop on runlevel [!2345]
	respawn
	script
	  /usr/bin/docker start -a docker-hub >>/var/log/docker-hub.log 2>&1
	end script

	```
5. (optional) Setup logrotate e.g. `/etc/logrotate.d/docker-hub`


	```
	/var/log/hub/*.log
	/var/log/hub/dashboard/*.log 
	/var/log/hub/hub/*.log 
	/var/log/hub/hub/logs/*.log 
	/var/log/hub/internal/services/bundleProcess/*.log 
	/var/log/hub/project-wizard/*.log 
	 {
	    rotate 7
	    daily
	    missingok
	    notifempty
	    sharedscripts
	    copytruncate
	    compress
	}
	```
6. (optional) Add vhost to nginx

	`mkdir -p /var/log/nginx/your-domain`

	```
	upstream docker-hub {
	  server localhost:8080;
	}

	server {
	  listen 80;
	  server_name           your-domain.com;

	  access_log            /var/log/nginx/your-domain/access.log;
	  error_log             /var/log/nginx/your-domain/error.log;

	  proxy_set_header Host       $http_host;   # required for docker client's sake
	  proxy_set_header X-Real-IP  $remote_addr; # pass on real client's IP

	  client_max_body_size 0; # disable any limits to avoid HTTP 413 for large image uploads

	  # required to avoid HTTP 411: see Issue #1486 (https://github.com/dotcloud/docker/issues/1486)
	  chunked_transfer_encoding on;

	  location / {
	    proxy_pass http://docker-hub;
	  }

	}
	```
7. Setup the Server
	
	Follow the steps 5-9 of the installation [instructions for Jetbrains Hub](https://www.jetbrains.com/hub/help/1.0/Installing-Hub-with-Zip-Distribution.html) using paths located under `/var/lib/hub/data`, `/var/lib/hub/backups`, `/var/log/hub`, `/tmp`.
