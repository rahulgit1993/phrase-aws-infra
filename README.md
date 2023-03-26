# Phrase Platform Task

## Summary

We have simple python [REST app](#rest-application). We would like to build docker container and run the app behind load balancer. The site should be accessible via HTTPS and some endpoints shouldn't be accessible from the internet.

There is a simple python [REST application](#rest-application). The goal of the assignment is to run the application inside the docker container and run the application behind the load balancer. The application should be accessible via HTTPS and some endpoints are considered private and should not be exposed publicly.

The result of the assignment should be presented as a GIT repository with reasonable history with code which allows to replicate the setup. Please use any reasonable language/format - like markdown, ansible, wiki, pupper, bash... - to document the approach in repeatable mode, also please make sure the server is available for review and further discussions.

## Tasks
### Prepare the server
* Create user `phrase_admin` without password capable to `sudo` without password, remote access via public key `phrase_admin.pub` should be allowed
* Create user `phrase_user` without any extra permissions, remote access via oublic key `phrase_user.pub` should be allowed
* Install basic packages like `curl`, `jq` and editor of your liking

### Dockerize the application
* Build the docker image of the application
* Prepare the DB (postgresql, mysql or mariadb) for the application with 2 users one user with full access for application and second  read-only user `developer`
* Start 2 containers with the REST application
* Deploy redis container and interconnect application containers with it
* The containers should start/restart automatically unless the container is stopped
 
 ### Loadbalancing and SSL
* Place the containers behind load balancer and balance traffic between them
* Everything should be available via HTTPS, HTTP should be automatically redirected to the HTTPS. Use self-signed or let's encrypt SSL certificate.
* `/admin` endpoint is behind basic auth protection, create one user `developer` with some password
* `/prepare-for-deploy` and `/ready-for-deploy` endpoint are blocked on load balancer and not available from the internet

### Deployment script
Prepare the script we can use for release new version of the application, use any reasonable framework, tooling, language or shell environment

The script should:

* Build new docker image with the application
* Stop containers with old version and deploy new version in zero-downtime mode if possible

### Other
* Use opensource tools you like and are used to
* Use technologies of your choice
* Let us know in case of any questions

## REST application

The application is simple python3 flask-based REST app. All requirements are in `requirements.txt`. Application needs connection for the database for single endpoint. You can control the application configuration via ENV variables:

```
APP_HOST=0.0.0.0
APP_PORT=5000
REDIS_HOST=redis
REDIS_PORT=6379
DATABASE_URI=sqlite:////tmp/test.db
DATABASE_URI=mysql+pymysql://user:password@host:3306/db_name
DATABASE_URI=postgresql+psycopg2://user:password@host:5432/db_name
```

Following commands can be used to operate with database and/or the application:

```
python create_db.py # create DB
python drop_db.py # drop DB
python app.py # Run application
```

Application endpoints are:
* `/` - hello world endpoint
* `/status` - status endpoint
* `/palindrom/<text>` - check if the text is palindrom, if true the text is stored in the DB
* `/admin` - admin area
* `/prepare-for-deploy` - prepare application for deployment
* `/ready-for-deploy` - confirms the app is ready for deployment
* `/redis-hits` - endpoint for testing redis connection

The application is ready once the `/status` is responding with `200` message `OK`. Not ready state results in `404` message `Not ready`.

You should wait on `/ready-for-deploy` with response `200` message `Ready` before you stop the application (lets pretend there are some async tasks in background which need to be completed).

### Notes

DB drivers `pymysql` and `psycopg2` are part of the `requirements.txt`, change them in case you have some problem with installation.
DB will fallback on `sqlite:////tmp/test.db`, you still have to create the structure via `create_db.py`

If there is anything you are blocked with feel free to skip it and move forward while documenting the issue and suggesting how it would be solved having more time.
