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
OPT="$( cd -P "$DIR/opt" && pwd )"
VAR="$( cd -P "$DIR/var" && pwd )"
SRC="$( cd -P "$DIR/src" && pwd )"
LOBA_DIR=${SRC}/jesse-greathouse/loba/lib
USER="$(whoami)"
LOG="${DIR}/error.log"
RUN_SCRIPT="${BIN}/run-amazon.sh"
SERVICE_RUN_SCRIPT="${BIN}/run-amazon-service.sh"
NGINX_CONF="${ETC}/nginx/nginx.conf"
SSL_CONF="${ETC}/ssl/openssl.cnf"
SSL_PARAMS_CONF="${ETC}/nginx/ssl-params.conf"
FORCE_SSL_CONF="${ETC}/nginx/force-ssl.conf"
PERL_BASE="${OPT}/perl"
PERL5LIB="${PERL_BASE}/lib/perl5"

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
printf "Enter the Admin Email: "
read ADMIN_EMAIL
printf "Create an Admin Password for the app: "
read -s ADMIN_PASSWORD
printf "\nConfirm the Admin Password: "
read -s ADMIN_PASSWORD_CONFIRM
if  [ "${ADMIN_PASSWORD}" != "${ADMIN_PASSWORD_CONFIRM}" ]; then
    printf "\nPassword confirmation failed. Please run this script again.\n"
    exit 1
fi
printf "\nEnter your name of your site [loba]: "
read SITE_NAME
if  [ "${SITE_NAME}" == "" ]; then
    SITE_NAME="loba"
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
printf "Enter your Google Oauth Client Id [optional]: "
read GOOGLE_OAUTH_CLIENT_ID
if  [ "${GOOGLE_OAUTH_CLIENT_ID}" == "" ]; then
    GOOGLE_OAUTH_CLIENT_ID="248720560989-j1jpfb3qv8s9thh3633nn8vfkpc484aq.apps.googleusercontent.com"
fi
printf "Enter your Google Oauth Client Secret [optional]: "
read GOOGLE_OAUTH_CLIENT_SECRET
if  [ "${GOOGLE_OAUTH_CLIENT_SECRET}" == "" ]; then
    GOOGLE_OAUTH_CLIENT_SECRET="qNZPihVIjV6Oon5ntBceZRqP"
fi
printf "Enter your database host [127.0.0.1]: "
read DB_HOST
if  [ "${DB_HOST}" == "" ]; then
    DB_HOST="127.0.0.1"
fi
printf "Enter your database driver [mysql]: "
read DB_DRIVER
if  [ "${DB_DRIVER}" == "" ]; then
    DB_DRIVER="mysql"
fi
printf "Enter your database name [loba]: "
read DB_NAME
if  [ "${DB_NAME}" == "" ]; then
    DB_NAME="loba"
fi
printf "Enter your database user [loba]: "
read DB_USER
if  [ "${DB_USER}" == "" ]; then
    DB_USER="loba"
fi
printf "Enter your database password [loba]: "
read DB_PASSWORD
if  [ "${DB_PASSWORD}" == "" ]; then
    DB_PASSWORD="loba"
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
printf "Use https? (y or n): "
read -n 1 SSL
if  [ "${SSL}" == "y" ]; then
    printf "\nDo you have a certificate and key pair?: (y or n): "
    read -n 1 SSL_PAIR
    if  [ "${SSL_PAIR}" == "y" ]; then
        printf "\nPath to certificate: (/path/to/certificate.crt): "
        read SSL_CERT
        if  [ "${SSL_CERT}" == "" ]; then
            printf "Please run this script again to enter the correct certificate location. \n"
            exit 1
        fi
        if [ ! -f ${SSL_CERT} ]; then
            printf "Certificate not found at: ${SSL_CERT}\n"
            printf "Please run this script again to enter the correct certificate location. \n"
            exit 1
        fi

        printf "Path to key: (/path/to/key.key): "
        read SSL_KEY
        if  [ "${SSL_KEY}" == "" ]; then
            printf "Please run this script again to enter the correct key location. \n"
            exit 1
        fi
        if [ ! -f ${SSL_KEY} ]; then
            printf "Key not found at: ${SSL_KEY}\n"
            printf "Please run this script again to enter the correct key location. \n"
            exit 1
        fi
    else
        printf "\nWould you like to create a self signed certificate and key pair? \n"
        printf "!!WARNING: NOT RECOMMENDED FOR A PRODUCTION ENVIRONMENT!! \n"
        printf "(y or n): "
        read -n 1 SSL_SELF_SIGNED
        if  [ "${SSL_SELF_SIGNED}" != "y" ]; then
            printf "\nPlease run this script again to enter the correct SSL imputs. \n"
            exit 1
        fi
    fi

    SSL="true"
else
    SSL="false"
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
printf "Admin Email: ${ADMIN_EMAIL} \n"
printf "Admin Password: ***** \n"
printf "Site Name: ${SITE_NAME} \n"
printf "Site Domains: ${SITE_DOMAINS} \n"
printf "Web Port: ${PORT} \n"
printf "Database Driver: ${DB_DRIVER} \n"
printf "Database Host: ${DB_HOST} \n"
printf "Database Name: ${DB_NAME} \n"
printf "Database User: ${DB_USER} \n"
printf "Database Password: ${DB_PASSWORD} \n"
printf "Database Port: ${DB_PORT} \n"
printf "Redis Host: ${REDIS_HOST} \n"
printf "Use Https: ${SSL} \n"
if [ "${SSL}" == "true" ]; then
    if  [ "${SSL_PAIR}" == "y" ]; then
        printf "SSL Cert: ${SSL_CERT} \n"
        printf "SSL Key: ${SSL_KEY} \n"
    else
        printf "Self signed key pair will be generated. \n"
    fi
fi
printf "Debug: ${DEBUG} \n"
printf "\n"
printf "Is this correct (y or n): "
read -n 1 CORRECT
printf "\n"

##==================================================================##
## The configurations options are confirmed, start templating here. ##
##==================================================================##

if  [ "${CORRECT}" == "y" ]; then

    ##============================
    ## Template SSL Config
    ##============================

    if [ -f ${SSL_CONF} ]; then
       rm ${SSL_CONF}
    fi
    cp ${ETC}/ssl/openssl.dist.cnf ${SSL_CONF}
    sed -i -e "s __ETC__ $ETC g" ${SSL_CONF}

    ##============================
    ## Template Run Script
    ##============================

    if [ -f ${RUN_SCRIPT} ]; then
       rm ${RUN_SCRIPT}
    fi
    cp ${BIN}/run.sh.dist ${RUN_SCRIPT}

    sed -i -e s/__ADMIN_EMAIL__/"${ADMIN_EMAIL}"/g ${RUN_SCRIPT}
    sed -i -e s/__SITE_NAME__/"${SITE_NAME}"/g ${RUN_SCRIPT}
    sed -i -e s/__PORT__/"${PORT}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_DRIVER__/"${DB_DRIVER}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_HOST__/"${DB_HOST}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_NAME__/"${DB_NAME}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_USER__/"${DB_USER}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_PASSWORD__/"${DB_PASSWORD}"/g ${RUN_SCRIPT}
    sed -i -e s/__REDIS_HOST__/"${REDIS_HOST}"/g ${RUN_SCRIPT}
    sed -i -e s/__DB_PORT__/"${DB_PORT}"/g ${RUN_SCRIPT}
    sed -i -e s/__GOOGLE_OAUTH_CLIENT_ID__/"${GOOGLE_OAUTH_CLIENT_ID}"/g ${RUN_SCRIPT}
    sed -i -e s/__GOOGLE_OAUTH_CLIENT_SECRET__/"${GOOGLE_OAUTH_CLIENT_SECRET}"/g ${RUN_SCRIPT}
    sed -i -e s/__SSL__/"${SSL}"/g ${RUN_SCRIPT}
    sed -i -e s/__DEBUG__/"${DEBUG}"/g ${RUN_SCRIPT}
    chmod +x ${RUN_SCRIPT}


    ##==============================
    ## Template the ssl-params.conf
    ##==============================

    # Generate Diffie-hellman param
    ${OPT}/perl/bin/perl ${BIN}/generate-diffie-hellman.pl --etc ${ETC}

    if [ -f ${SSL_PARAMS_CONF} ]; then
       rm ${SSL_PARAMS_CONF}
    fi
    cp ${ETC}/nginx/ssl-params.dist.conf ${SSL_PARAMS_CONF}

    sed -i -e "s __ETC__ $ETC g" ${SSL_PARAMS_CONF}


    ##==============================
    ## Template the force-ssl.conf
    ##==============================

    if [ -f ${FORCE_SSL_CONF} ]; then
        rm ${FORCE_SSL_CONF}
    fi
    cp ${ETC}/nginx/force-ssl.dist.conf ${FORCE_SSL_CONF}
    sed -i -e s/__SITE_DOMAINS__/"${SITE_DOMAINS}"/g ${FORCE_SSL_CONF}


    ##==============================
    ## Template the nginx.conf
    ##==============================

    if [ -f ${NGINX_CONF} ]; then
       rm ${NGINX_CONF}
    fi
    cp ${ETC}/nginx/nginx.dist.conf ${NGINX_CONF}

    SESSION_SECRET=`openssl rand -hex 32`

    sed -i -e s/__USER__/"${USER}"/g ${NGINX_CONF}
    sed -i -e "s __LOG__ $LOG g" ${NGINX_CONF}
    sed -i -e s/__SITE_DOMAINS__/"${SITE_DOMAINS}"/g ${NGINX_CONF}
    sed -i -e s/__PORT__/"${PORT}"/g ${NGINX_CONF}
    sed -i -e s/__SESSION_SECRET__/"${SESSION_SECRET}"/g ${NGINX_CONF}

    ## If the "Use https" option was selected, configure the nginx.conf for SSL
    if [ "${SSL}" == "true" ]; then
        SSL_FLAG="ssl"

        ## Directives for the SSL cert and key
        SSL_CERT_LINE="ssl_certificate\\ ${ETC}/ssl/certs/loba.crt;"
        SSL_KEY_LINE="ssl_certificate_key\\ ${ETC}/ssl/private/loba.key;"
    
        ## If there is a SSL Key Pair, provided by the user, copy them in place
        if  [ "${SSL_PAIR}" == "y" ]; then
            # Checking to see if the provided key pair already exists
            # If the user supplied a new key pair, then replace it
            # If the key pair already exists, then  do nothing

            # If the cert doesn't exist, copy into place
            if [ ! -f ${ETC}/ssl/certs/loba.crt ]; then
                cp ${SSL_CERT} ${ETC}/ssl/certs/loba.crt
            else
                ## if the provided cert is different, remove the old and replace it
                if [ -n  "$(cmp ${ETC}/ssl/certs/loba.crt ${SSL_CERT})" ]; then
                    rm ${ETC}/ssl/certs/loba.crt
                    cp ${SSL_CERT} ${ETC}/ssl/certs/loba.crt
                else
                    printf "The provided cert is already in use. Skipping...\n"
                fi
            fi

            # If the key doesn't exist, copy into place
            if [ ! -f ${ETC}/ssl/private/loba.key ]; then
                cp ${SSL_KEY} ${ETC}/ssl/private/loba.key
            else
                ## if the provided key is different, remove the old and replace it
                if [ -n  "$(cmp ${ETC}/ssl/private/loba.key ${SSL_KEY})" ]; then
                    rm ${ETC}/ssl/private/loba.key
                    cp ${SSL_KEY} ${ETC}/ssl/private/loba.key
                else
                    printf "The provided key is already in use. Skipping...\n"
                fi
            fi

        else
            SSL_CERT="${ETC}/ssl/certs/loba.crt"
            SSL_KEY="${ETC}/ssl/private/loba.key"
            CORRECTED_DOMAINS=`echo ${SITE_DOMAINS} | sed 's/ /_/g'`
            
            if [[ ! -f ${SSL_CERT}  ||  ! -f ${SSL_KEY} ]]; then
                if [ -f ${SSL_CERT} ]; then
                    rm ${SSL_CERT};
                fi

                if [ -f ${SSL_KEY} ]; then
                    rm ${SSL_KEY};
                fi

                openssl req \
                -x509 -nodes -days 365 -newkey rsa:2048 \
                -writerand ${ETC}/ssl/.rnd \
                -subj "/CN=${CORRECTED_DOMAINS}" \
                -config ${ETC}/ssl/openssl.cnf \
                -keyout ${SSL_KEY} \
                -out ${SSL_CERT}

            else 
                printf "SSL Key pair already exists. Skipping... \n"
            fi
        fi

        INCLUDE_FORCE_SSL="include\\ ${FORCE_SSL_CONF};"
    fi

    ## Template lines will be blank if the "Use https" option was not selected
    sed -i -e s/__SSL__/${SSL_FLAG}/g ${NGINX_CONF}
    sed -i -e "s __SSL_CERT_LINE__ $SSL_CERT_LINE g" ${NGINX_CONF}
    sed -i -e "s __SSL_KEY_LINE__ $SSL_KEY_LINE g" ${NGINX_CONF}
    sed -i -e "s __INCLUDE_FORCE_SSL__ $INCLUDE_FORCE_SSL g" ${NGINX_CONF}


    ##==================================================================
    ## Initialize the database and populate the admin user and password
    ##==================================================================

    printf "Initializing the database... \n"
    ETC=${ETC} \
    LOBA_DIR=${LOBA_DIR} \
    SQL_QUERY_DIR=${LOBA_DIR}/sql/${DB_DRIVER} \
    LOG_DIR=${VAR}/logs \
    CACHE_DIR=${VAR}/cache \
    DB_DRIVER=${DB_DRIVER} \
    DB_HOST=${DB_HOST} \
    DB_USER=${DB_USER} \
    DB_PASSWORD=${DB_PASSWORD} \
    DB_NAME=${DB_NAME} \
    DB_PORT=${DB_PORT} \
    PERL5LIB=${PERL5LIB} \
    ${PERL_BASE}/bin/perl ${BIN}/db-init.pl
    printf "Database tables created.\n"


    ##==========================================
    ## Create the Admin user, password and roles
    ##==========================================

    printf "Creating the Admin user, password and roles... \n"
    ADMIN_EMAIL=${ADMIN_EMAIL} \
    ADMIN_PASSWORD=${ADMIN_PASSWORD} \
    SQL_QUERY_DIR=${LOBA_DIR}/sql/${DB_DRIVER} \
    DB_DRIVER=${DB_DRIVER} \
    DB_HOST=${DB_HOST} \
    DB_USER=${DB_USER} \
    DB_PASSWORD=${DB_PASSWORD} \
    DB_NAME=${DB_NAME} \
    DB_PORT=${DB_PORT} \
    PERL5LIB=${PERL5LIB} \
    ${PERL_BASE}/bin/perl ${BIN}/create-admin.pl
    printf "Admin created.\n"

    # Set up SSL port
    if [ ! -f "/etc/authbind/byport/443" ]; then
        sudo touch /etc/authbind/byport/443
        sudo chown ${USER} /etc/authbind/byport/443
        sudo chmod 500 /etc/authbind/byport/443
    fi

    # Allow binding to ports if below 1025
    if [ "$PORT" -lt "1025" -a "$PORT" -ne "443" -a ! -f "/etc/authbind/byport/$PORT" ]; then
        sudo touch /etc/authbind/byport/${PORT}
        sudo chown ${USER} /etc/authbind/byport/${PORT}
        sudo chmod 500 /etc/authbind/byport/${PORT}
    fi

    printf "\n"
    printf "\n"
    printf "\n"
    printf "================================================================\n"
    printf "Your run script has been created at: \n"
    printf "${RUN_SCRIPT}\n"
    printf "\n"
else
    printf "Please run this script again to enter the correct configuration. \n"
    printf "\n"
    printf "================================================================\n"
    exit 1
fi

if [ -f ${SERVICE_RUN_SCRIPT} ]; then
    rm ${SERVICE_RUN_SCRIPT}
fi

cp ${RUN_SCRIPT} ${SERVICE_RUN_SCRIPT}

sed -i 's/supervisord.conf/supervisord.service.conf/' ${SERVICE_RUN_SCRIPT}

printf "Creating startup script...\n"

INITD_SCRIPT="${ETC}/init.d/${SITE_NAME}.sh"
STOP_SCRIPT="${BIN}/stop.sh"

if [ -f ${INITD_SCRIPT} ]; then
   rm ${INITD_SCRIPT}
fi

cp "${ETC}/init.d/init-template.sh.dist" ${INITD_SCRIPT}

chmod +x "${INITD_SCRIPT}"

sed -i -e "s __START_SCRIPT__ $SERVICE_RUN_SCRIPT " ${INITD_SCRIPT}
sed -i -e "s __STOP_SCRIPT__ $STOP_SCRIPT " ${INITD_SCRIPT}

printf "\n"
printf "First copy the startup script into init.d by pasting this into the console:\n"
printf "sudo cp ${INITD_SCRIPT} /etc/init.d/${SITE_NAME}\n"
printf "\n";
printf "Then to run the website when the system boots paste this into the console: \n"
printf "sudo chkconfig --add ${SITE_NAME}; sudo chkconfig --level 2345 ${SITE_NAME} on\n"
printf "\n";
printf "To start the website now, use the script to start it, like this: \n"
printf "sudo /etc/init.d/${SITE_NAME} start\n"
printf "\n";
printf "================================================================\n"
