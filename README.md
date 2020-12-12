# docker-bugzilla
A docker container to get the lastest version of bugzilla from github and run.

It uses Alpine Linux, Apache2 and an existing MariaDB.

## Running on ARM / RPi
This docker is created to run on a Raspberry Pi 4 using docker-compose. Currently it is in the build-up phase and the following sections of this REAMDE.md are not updated.

## Installation

### Step 1 - Start the Server



### Step 2 - Add a User



### Step 3 - Enable Auto Discovery



### Step 4 - Configure Your Firewall


### Step 5 - Start Using It

## Advanced Usage

### Configure using environment variables

You can configure the container using environment variables (for example, if you use a `docker-compose` environment).

There are these environment variables:
* **DB_HOST**: Database hostname
* **DB_LOGIN**: Database Root User name
* **DB_PASSWORD**: Database Root password

Using these variables, the container will create a Database user at create time.

