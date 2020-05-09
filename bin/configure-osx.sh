#!/usr/bin/env bash

#   +---------------------------------------------------------------------------------+
#   | This file is part of greathouse-openresty                                       |
#   +---------------------------------------------------------------------------------+
#   | Copyright (c) 2017 Greathouse Technology LLC (http://www.greathouse.technology) |
#   +---------------------------------------------------------------------------------+
#   | greathouse-openresty is free software: you can redistribute it and/or modify    |
#   | it under the terms of the GNU General Public License as published by            |
#   | the Free Software Foundation, either version 3 of the License, or               |
#   | (at your option) any later version.                                             |
#   |                                                                                 |
#   | greathouse-openresty is distributed in the hope that it will be useful,         |
#   | but WITHOUT ANY WARRANTY; without even the implied warranty of                  |
#   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   |
#   | GNU General Public License for more details.                                    |
#   |                                                                                 |
#   | You should have received a copy of the GNU General Public License               |
#   | along with greathouse-openresty.  If not, see <http://www.gnu.org/licenses/>.   |
#   +---------------------------------------------------------------------------------+
#   | Author: Jesse Greathouse <jesse@greathouse.technology>                          |
#   +---------------------------------------------------------------------------------+

# This script will prompt the user to provide necessary strings
# to customize their run script

# resolve real path to script including symlinks or other hijinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ ${TARGET} == /* ]]; then
    printf "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    BIN="$( dirname "$SOURCE" )"
    printf "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$BIN')"
    SOURCE="$BIN/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
RBIN="$( dirname "$SOURCE" )"
BIN="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
DIR="$( cd -P "$BIN/../" && pwd )"
ETC="$( cd -P "$DIR/etc" && pwd )"
TMP="$( cd -P "$DIR/tmp" && pwd )"
USER="$(whoami)"
LOG="${DIR}/error.log"
RUN_SCRIPT="${BIN}/run-osx.sh"
SERVICE_RUN_SCRIPT="${BIN}/run-osx-service.sh"
NGINX_CONF="${ETC}/nginx/nginx.conf"

printf "\n"
printf "\n"
printf "+---------------------------------------------------------------------------------+\n"
printf "| Thank you for choosing greathouse-openresty                                     |\n"
printf "+---------------------------------------------------------------------------------+\n"
printf "| Copyright (c) 2017 Greathouse Technology LLC (http://www.greathouse.technology) |\n"
printf "+---------------------------------------------------------------------------------+\n"
printf "| greathouse-openresty is free software: you can redistribute it and/or modify    |\n"
printf "| it under the terms of the GNU General Public License as published by            |\n"
printf "| the Free Software Foundation, either version 3 of the License, or               |\n"
printf "| (at your option) any later version.                                             |\n"
printf "|                                                                                 |\n"
printf "| greathouse-openresty is distributed in the hope that it will be useful,         |\n"
printf "| but WITHOUT ANY WARRANTY; without even the implied warranty of                  |\n"
printf "| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   |\n"
printf "| GNU General Public License for more details.                                    |\n"
printf "|                                                                                 |\n"
printf "| You should have received a copy of the GNU General Public License               |\n"
printf "| along with greathouse-openresty.  If not, see <http://www.gnu.org/licenses/>.   |\n"
printf "+---------------------------------------------------------------------------------+\n"
printf "| Author: Jesse Greathouse <jesse@greathouse.technology>                          |\n"
printf "+---------------------------------------------------------------------------------+\n"
printf "\n"
printf "\n"
printf "=================================================================\n"
printf "Hello, "${USER}".  This will create your site's run script\n"
printf "=================================================================\n"
printf "\n"
printf "Enter your name of your site [MySite]: "
read SITE_NAME
if  [ "${SITE_NAME}" == "" ]; then
    SITE_NAME="MySite"
fi
printf "Enter the domains of your site [127.0.0.1 localhost]: "
read SITE_DOMAINS
if  [ "${SITE_DOMAINS}" == "" ]; then
    SITE_DOMAINS="127.0.0.1 localhost"
fi
printf "Enter your website port [80]: "
read PORT
if  [ "${PORT}" == "" ]; then
    PORT="80"
fi
printf "Enter your database host [127.0.0.1]: "
read DB_HOST
if  [ "${DB_HOST}" == "" ]; then
    DB_HOST="127.0.0.1"
fi
printf "Enter your database name [db_name]: "
read DB_NAME
if  [ "${DB_NAME}" == "" ]; then
    DB_NAME="db_name"
fi
printf "Enter your database user [db_user]: "
read DB_USER
if  [ "${DB_USER}" == "" ]; then
    DB_USER="db_user"
fi
printf "Enter your database password [db_password]: "
read DB_PASSWORD
if  [ "${DB_PASSWORD}" == "" ]; then
    DB_PASSWORD="db_password"
fi
printf "Enter your database port [3306]: "
read DB_PORT
if  [ "${DB_PORT}" == "" ]; then
    DB_PORT="3306"
fi
printf "Enter your redis host [127.0.0.1]: "
read REDIS_HOST
if  [ "${REDIS_HOST}" == "" ]; then
    REDIS_HOST="127.0.0.1"
fi
printf "Force visitors to https? (y or n): "
read -n 1 FORCE_SSL
if  [ "${FORCE_SSL}" == "y" ]; then
    FORCE_SSL="true"
else
    FORCE_SSL="false"
fi
printf "\nDebug (Not recommended for production environments) (y or n): "
read -n 1 DEBUG
if  [ "${DEBUG}" == "n" ]; then
    DEBUG="false"
else
    DEBUG="true"
fi

printf "\n"
printf "You have entered the following configuration: \n"
printf "\n"
printf "Site Name: ${SITE_NAME} \n"
printf "Site Domains: ${SITE_DOMAINS} \n"
printf "Web Port: ${PORT} \n"
printf "Database Host: ${DB_HOST} \n"
printf "Database Name: ${DB_NAME} \n"
printf "Database User: ${DB_USER} \n"
printf "Database Password: ${DB_PASSWORD} \n"
printf "Database Port: ${DB_PORT} \n"
printf "Redis Host: ${REDIS_HOST} \n"
printf "Force Https: ${FORCE_SSL} \n"
printf "Debug: ${DEBUG} \n"
printf "\n"
printf "Is this correct (y or n): "
read -n 1 CORRECT
printf "\n"

if  [ "${CORRECT}" == "y" ]; then

    if [ -f ${RUN_SCRIPT} ]; then
       rm ${RUN_SCRIPT}
    fi
    cp ${BIN}/run.sh.dist ${RUN_SCRIPT}

    sed -i '' '1 a\
        PATH=/usr/local/bin:$PATH' ${RUN_SCRIPT}
    sed -i '' s/__SITE_NAME__/"${SITE_NAME}"/g ${RUN_SCRIPT}
    sed -i '' s/__PORT__/"${PORT}"/g ${RUN_SCRIPT}
    sed -i '' s/__DB_HOST__/"${DB_HOST}"/g ${RUN_SCRIPT}
    sed -i '' s/__DB_NAME__/"${DB_NAME}"/g ${RUN_SCRIPT}
    sed -i '' s/__DB_USER__/"${DB_USER}"/g ${RUN_SCRIPT}
    sed -i '' s/__DB_PASSWORD__/"${DB_PASSWORD}"/g ${RUN_SCRIPT}
    sed -i '' s/__REDIS_HOST__/"${REDIS_HOST}"/g ${RUN_SCRIPT}
    sed -i '' s/__DB_PORT__/"${DB_PORT}"/g ${RUN_SCRIPT}
    sed -i '' s/__FORCE_SSL__/"${FORCE_SSL}"/g ${RUN_SCRIPT}
    sed -i '' s/__DEBUG__/"${DEBUG}"/g ${RUN_SCRIPT}
    chmod +x ${RUN_SCRIPT}

    if [ -f ${NGINX_CONF} ]; then
       rm ${NGINX_CONF}
    fi
    cp ${ETC}/nginx/nginx.dist.conf ${NGINX_CONF}

    SESSION_SECRET=`openssl rand -hex 32`

    sed -i '' "s __LOG__ $LOG g" ${NGINX_CONF}
    sed -i '' s/__SITE_DOMAINS__/"${SITE_DOMAINS}"/g ${NGINX_CONF}
    sed -i '' s/__PORT__/"${PORT}"/g ${NGINX_CONF}
    sed -i '' s/__SESSION_SECRET__/"${SESSION_SECRET}"/g ${NGINX_CONF}

printf "\n"
printf "\n"
printf "\n"
printf "================================================================\n"
printf "\n"

    printf "Your run script has been created. \n"
    printf "To run your website only once paste this script into the console:  \n"
    printf "${RUN_SCRIPT}\n"
    printf "\n"
else
    printf "Please run this script again to enter the correct configuration. \n"
    printf "\n"
    printf "================================================================\n"
    exit 1
fi

printf "Creating startup script...\n"

LAUNCHD_CONF="${ETC}/com.jesse-greathuse.${SITE_NAME}.plist"

if [ -f ${LAUNCHD_CONF} ]; then
   rm ${LAUNCHD_CONF}
fi

cp "${ETC}/com.greathouse.technology.template.plist" ${LAUNCHD_CONF}

sed -i '' "s __LABEL__ $SITE_NAME " ${LAUNCHD_CONF}
sed -i '' "s __RUN_SCRIPT__ $RUN_SCRIPT " ${LAUNCHD_CONF}
sed -i '' "s __ERROR_PATH__ $DIR/error.log " ${LAUNCHD_CONF}
sed -i '' "s __STANDARD_OUT_PATH__ $DIR/supervisord.log " ${LAUNCHD_CONF}
sed -i '' "s __WORKING_DIRECTORY__ $DIR " ${LAUNCHD_CONF}

printf "To run the website when OSX boots, paste this into the console: \n"
printf "sudo cp -f ${LAUNCHD_CONF} /Library/LaunchDaemons\n"
printf "\n";
printf "================================================================\n"