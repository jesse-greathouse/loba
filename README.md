# Loba
A load balancer made from Nginx and LuaJIT with Openresty

## Installation

## Database
Loba builds its own dependencies however there are some resources that loba will require like a database.

Currently the only supported database is MySQL, however it is possible that new database modules can be added because Loba is built to support multiple databases. It may also be possible to use MariaDB with Loba due to its interchangability with MySQL.

Loba depends on the database to do its own encryption of passwords and tokens so that the open source nature of this application will not be the sole determination of the encryption algorithms that any instance may use. To do this, Loba depends on database triggers to encrypt passwords and tokens.

### Getting started with MySQL

Before installation you will need to set up the Schema and user permissions for Loba.

  * Create the schema.
    * ```mysql> CREATE SCHEMA `loba2`;```
  * Create the Loba user
    * ```mysql> CREATE USER 'loba'@'localhost' IDENTIFIED BY 'password';```
  * Grant the Loba user permissions for the Loba schema
    * ```mysql> GRANT PRIVILEGE ON loba.* TO 'loba'@'localhost';```

The Specifics of how you set up this user may depend on your preference and the version of MySQL that you use. This example was meant to show a configuration that can get you started, but is by no means the exact way that you must set up this user and these permissions. Do your own dilligence in making this configuration right for your specific use.

#### Triggers
If you would like to use the default encryption triggers, out of the box, it's easy to get started, and the install sequence will take care of this for you when it builds the database. In order for the triggers to be created, you will need to add a setting to your MySQL server, so that the server will [trust the functions that Loba creates](https://dev.mysql.com/doc/refman/5.7/en/stored-programs-logging.html).

There are two ways of doing this:
  * You may add the setting to your `my.cnf`:
    * ```log_bin_trust_function_creators=1```
  * You may also change the setting in your SQL console as an admin:
    * ```mysql> SET GLOBAL log_bin_trust_function_creators = 1;```

## Redis
Loba can take advantage of a Redis instance if one is available. To look into installing Redis, you will need to check out the [Redis official documentation](https://redis.io/download/).

## Install Script
Loba supports several platforms and there are install scripts for each respective platform:
  * Amazon
    * ```bin/install-amazon.sh```
  * CentOS
    * ```bin/install-centos.sh```
  * MacOS
    * ```bin/install-osx.sh```
  * RHEL
    * ```bin/install-rhel.sh```
  * Ubuntu
    * ```bin/install-ubuntu.sh```
  * Docker
    * Docker uses Alpine Linux and does not require installation because the image has already been built and is publicly available. Docker is not recommended for live production use.

The install script accomplishes several things:
  * It installs the dependencies on the system. For this, administrative privelages will be required and you will be required to enter your sudo password every time the system needs elevated privelages to install.
    * Loba does not run as an administrator, but it does need these dependencies to be installed on the system. When you run Loba, it will run without elevated privelages, the install is the only time it needs elevated privelages.
  * It installs and arranges [autoconf](https://www.gnu.org/software/autoconf/). Autoconf is a tool which allows Loba to serve system ports, like port 80 and 443, without elevated privelages.
    * Elevated privelages are normally required for applications that serve on these ports, however Loba does not run with elevated privelages and so autoconf bridges the necessity of opening these ports for Loba, without allowing Loba to have elevated privelages.
  * It installs [Openresty](https://openresty.org/en/).
    * Open resty is a web platform that integrates Nginx with LuaJIT and allows for programming in the Lua programming language. Loba's API is written in Lua.
  * It installs the Perl [Template Toolkit](https://metacpan.org/pod/Template) and [DBM](https://metacpan.org/pod/DBD::DBM) modules.
  * It installs [Angular](https://angular.io/).
    * The Loba user interface is built on Angular with Typescript.
  * Loba installs these programs discretly into its own appplication folder under `./opt`.
    * This allows Loba to use its own versions of Nginx, LuaJIT, and Perl Modules, without depending on or interfering with the system wide installations of these programs.
  * After the install script is finished Loba will automatically run the configure script for the intended OS.

## Configure Script
Just like the install script, Loba supports the same platforms for its configuration script:
  * Amazon
    * ```bin/configure-amazon.sh```
  * CentOS
    * ```bin/configure-centos.sh```
  * MacOS
    * ```bin/configure-osx.sh```
  * RHEL
    * ```bin/configure-rhel.sh```
  * Ubuntu
    * ```bin/configure-docker.sh```
  * Docker
    * ```bin/configure-docker.sh```

The configure script will bring the user through a series of prompts to set the initial configuration of the app. The configure script can be run at any time to re-configure the app, but be aware that when the configure script is finalized, the previous configuration will be lost.

![configuration example](https://i.imgur.com/AZTuGOu.png)

When the user accepts that the configuration is correct, the configuration will be created and finalized.

The configuration script creates the run script. For example:
```bin/run-osx.sh```

The run script may be executed add-hoc, to start Loba. You may also use `control-c` to cancel the script because it will be executed live in the console:

![run example](https://i.imgur.com/v9ED8cD.png)

The configuration script will also output the instructions for running Loba as a service for your specific operating system.

## Application
At this point the application installation is complete. You should be able to access the Loba User Interface by going to the domain that you specified in the configuration.

![application login](https://i.imgur.com/3Eotdd2.png)

## Build Docker Container
docker build -t jessegreathouse/loba:latest .