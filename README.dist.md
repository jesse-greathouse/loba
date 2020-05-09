greathouse-openresty
====
# How to Install
These instructions assume that you've already created a useable database for your application, along with having the required credentials. If you do not need a database, you can ignore the database credentials or set them as placeholders for later. If you need help on creating a database, you can [learn how, here](https://www.postgresql.org/docs/10/tutorial-install.html).

* Download the git repository
    * `git clone https://github.com/jesse-greathouse/greathouse-openresty`
* Change to the greathouse-openresty directory
    * `cd greathouse-openresty`

## Docker Installation
* The easiest way to run greathouse-openresty is with Docker. You will need to install docker on your web host. Check the [Official Docker Site](https://docs.docker.com/engine/installation/) on how to install Docker on your host.
    * [Ubuntu](https://docs.docker.com/engine/installation/linux/ubuntu/)
    * [Red Hat Enterprise Linux](https://docs.docker.com/engine/installation/linux/rhel/)
    * [CentOs](https://docs.docker.com/engine/installation/linux/centos/)
    * [Fedora](https://docs.docker.com/engine/installation/linux/fedora/)
    * [Debian](https://docs.docker.com/engine/installation/linux/debian/)
    * [OSX](https://docs.docker.com/docker-for-mac/install/)
    * [Windows](https://docs.docker.com/docker-for-windows/install/)
    * [Docker EE for Windows Server](https://docs.docker.com/docker-ee-for-windows/install/)
    * [Docker-AWS](https://docs.docker.com/docker-for-aws/)
    * [Docker-Azure](https://docs.docker.com/docker-for-azure/)
* Run the configuration script
    * `bin/configure-docker.sh`


# Docker Management Instructions
## Building the App
    docker build -t jessegreathouse/greathouse-openresty .

## Pushing the App
    docker push jessegreathouse/greathouse-openresty

## Running the APP
    docker run -d -p 3000:3000 \
        -e ENV=prod \
        -e DEBUG=false \
        -e FORCE_SSL=false \
        -e DIR="/app" \
        -e BIN="/app/bin" \
        -e ETC="/app/etc" \
        -e OPT="/app/opt" \
        -e SRC="/app/src" \
        -e TMP="/app/tmp" \
        -e VAR="/app/var" \
        -e WEB="/app/web" \
        -e CACHE_DIR="/app/var/cache" \
        -e LOG_DIR="/app/var/logs" \
        -e REDIS_HOST=redis \
        -e DB_NAME="db_name" \
        -e DB_USER="db_user" \
        -e DB_PASSWORD="db_password" \
        -e DB_HOST="192.168.0.1" \
        -e DB_PORT=3306 \
        -v $(pwd)/error.log:/app/error.log \
        -v $(pwd)/supervisord.log:/app/supervisord.log \
        -v $(pwd)/etc/nginx/nginx.conf:/app/etc/nginx/nginx.conf \
        --restart no \
        --name my-site \
        jessegreathouse/greathouse-openresty

* check [http://localhost:3000/](http://localhost:3000/)

# Running Tests
    docker exec -ti greathouse-openrestys run_tests.sh
