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

# resolve real path to script including symlinks or other hijinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ ${TARGET} == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    BIN="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$BIN')"
    SOURCE="$BIN/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
USER="$( whoami )"
RBIN="$( dirname "$SOURCE" )"
BIN="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
DIR="$( cd -P "$BIN/../" && pwd )"
ETC="$( cd -P "$DIR/etc" && pwd )"
OPT="$( cd -P "$DIR/opt" && pwd )"
SRC="$( cd -P "$DIR/src" && pwd )"
PUBLIC="$( cd -P "$DIR/web" && pwd )"
PERL_BASE="${OPT}/perl"
PERL_MM_OPT="INSTALL_BASE=${PERL_BASE}"
PERL_MB_OPT="--install_base ${PERL_BASE}"
PERL5LIB="${PERL_BASE}/lib/perl5"

# install dependencies
sudo yum -y update && sudo yum -y install \
    gcc gcc-c++ git-core gmp-devel openssl-devel openssl-libs openssl \
    libcurl-devel curl pkgconfig libtool-ltdl-devel readline-devel libicu-devel \
    zlib-devel zlib ncurses-devel cmake sendmail mariadb-devel python mariadb-client

sudo easy_install supervisor

export PATH=$PATH:/usr/local/mysql/bin

# Compile and Install Openresty
tar -xzf ${OPT}/openresty-*.tar.gz -C ${OPT}/

# Fix the escape frontslash feature of cjson
sed -i -e s/"    NULL, NULL, NULL, NULL, NULL, NULL, NULL, \"\\\\\\\\\/\","/"    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,"/g ${OPT}/openresty-*/bundle/lua-cjson-2.1.0.7/lua_cjson.c

cd ${OPT}/openresty-*/
./configure --with-cc-opt="-I/usr/local/include -I/usr/local/opt/openssl/include" \
            --with-ld-opt="-L/usr/local/lib -L/usr/local/opt/openssl/lib" \
            --prefix=${OPT}/openresty \
            --with-pcre-jit \
            --with-ipv6 \
            --with-http_iconv_module \
            --with-http_realip_module \
            --with-http_ssl_module \
            -j2 && \
make
make install

cd ${DIR}

# Compile Perl 5.30.2
tar -xf ${OPT}/perl-*.tar.gz -C ${OPT}/

cd ${OPT}/perl-*/

./Configure -des -Dprefix=${OPT}/perl
make
make install

curl -L http://cpanmin.us | ${OPT}/perl/bin/perl - App::cpanminus

# Install perl modules
PERL_MM_OPT=${PERL_MM_OPT} PERL_MB_OPT=${PERL_MB_OPT} PERL5LIB=${PERL5LIB} ${OPT}/perl/bin/cpanm DBI DBD::mysql Template

cd ${DIR}

# Cleanup
ln -sf ${OPT}/openresty/nginx/sbin/nginx ${BIN}/nginx
ln -sf ${OPT}/perl/bin/perl ${BIN}/perl
rm -rf ${OPT}/openresty-*/
rm -rf ${OPT}/perl-*/

${BIN}/configure-amazon.sh