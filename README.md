# docker-bugzilla
A docker container to get the lastest version of bugzilla from github and run.

It uses Ubuntu 20.04, Apache2 and an existing MariaDB.

## Running on ARM / RPi
This docker is created to run on a Raspberry Pi 4 using docker-compose. Currently it is in the build-up phase and the following sections of this REAMDE.md are not updated.

## Configuration
### Configure using environment variables

You can configure the container using environment variables (for example, if you use a `docker-compose` environment).

There are these environment variables:
* **BUGZILLA_DB_HOST**: Database hostname
* **BUGZILLA_DB_LOGIN**: Database Root User name
* **BUGZILLA_DB_PASS**: Database Root password
* **BUGZILLA_DB_NAME**: Database Name
* **SERVERADMIN_EMAIL**: email address of the serveradmin (i.e. webmaster@foo.com)
* **SERVERNAME**: the URL your bugzilla server answers to (i.e. http://mybugs.foo.com)


### Step 1 - Preparation Database
* creata a database in your local MariaDB server for a specific bugzilla user, ensure to create a strong password, and be sure that the database can be connected from other docker machines (you might want to create a docker network connecting your docker containers, see the docker or docker-compose documentation for details)


### Step 2 - Preparation Config

* create a docker-compose.yml file containing the necessary config to run your server

### Step 3 - start the database and server

* remember to have started your database server 

* start bugzilla-docker by the '''docker-compose up <containername>''' command and observe the output for errors
* if that worked, exit with Ctrl-C and start it again with '''docker-compose up -d <containername>'''

## Maintenance and Backup


