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

FROM alpine:3.11
LABEL maintainer="Jesse Greathouse <jesse.greathouse@gmail.com>"

ENV PATH /app/bin:$PATH

# Get core utils
RUN apk add --no-cache \
    bash curl openssh nasm dpkg-dev dpkg file coreutils libc-dev ncurses-dev curl-dev \
    libressl-dev python py-curl supervisor pcre-dev perl mariadb-dev mariadb-connector-c \
    g++ gcc make ca-certificates pkgconf mysql-client readline-dev 

# Add preliminary file structure
RUN mkdir /app
RUN mkdir /app/bin
RUN mkdir /app/etc
RUN mkdir /app/opt
RUN mkdir /app/tmp
RUN mkdir /app/tmp/session
RUN mkdir /app/var
RUN mkdir /app/var/cache
RUN mkdir /app/var/logs
RUN touch /app/error.log
ADD opt /app/opt

# Add Scripts
ADD bin/install.sh /app/bin/install.sh
ADD bin/compile-modules.pl /app/bin/compile-modules.pl
ADD bin/db-init.pl /app/bin/db-init.pl
ADD bin/compose-sites.pl /app/bin/compose-sites.pl

WORKDIR /app

# Run the install script
RUN bin/install.sh

# Remove all dependency tarballs
RUN rm -rf /app/opt/*tar.gz

# Project files
ADD etc/ /app/etc
ADD web/ /app/web
ADD src/ /app/src

# Expose ports
EXPOSE 3000

CMD ["/usr/bin/supervisord", "-c", "/app/etc/supervisor/conf.d/supervisord.conf"]