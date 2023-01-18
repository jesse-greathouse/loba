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
GROUP="$( users )"
RBIN="$( dirname "$SOURCE" )"
BIN="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
DIR="$( cd -P "$BIN/../" && pwd )"
ETC="$( cd -P "$DIR/etc" && pwd )"
OPT="$( cd -P "$DIR/opt" && pwd )"
SRC="$( cd -P "$DIR/src" && pwd )"
WEB="$( cd -P "$DIR/web" && pwd )"
PUBLIC="$( cd -P "$DIR/web" && pwd )"
YACC="$( brew --prefix bison )/bin/bison"

#install dependencies
brew upgrade

brew install intltool icu4c autoconf automake python@3.8 gcc \
  pcre curl-openssl libiconv pkg-config openssl@1.1 mysql-client cpanm

#install authbind -- allows a non root user to allow a program to bind to a port under 1025
cd ${OPT}
rm -rf ${OPT}/MacOSX-authbind/
git clone https://github.com/Castaglia/MacOSX-authbind.git
cd ${OPT}/MacOSX-authbind
make
sudo make install
cd ${DIR}

# If curl isn't available to the command line then add it to the PATH
if ! [ -x "$(command -v curl)" ]; then
  echo 'export PATH="/usr/local/opt/curl/bin:$PATH"' >> ~/.bash_profile
  export PATH="/usr/local/opt/curl/bin:${PATH}"
fi

# install supervisor with pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
chmod +x get-pip.py
python3 get-pip.py
rm get-pip.py
pip install supervisor

# install angular cli
npm install -g @angular/cli

export PATH=$PATH:/usr/local/mysql/bin

# Compile and Install Openresty
tar -xf ${OPT}/openresty-*.tar.gz -C ${OPT}/

# Fix the escape frontslash feature of lua-cjson
sed -i '' s/"    NULL, NULL, NULL, NULL, NULL, NULL, NULL, \"\\\\\\\\\/\","/"    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,"/g ${OPT}/openresty-*/bundle/lua-cjson-2.1.0.10/lua_cjson.c

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
make install

cd ${DIR}

# Install perl modules
sudo cpanm DBI DBD::mysql Template
sudo cpanm DBI DBD::mysql DBI
sudo cpanm DBI DBD::mysql DBD::mysql

# Install nvm and angular
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 14.4
nvm use 14.4
npm install -g @angular/cli

cd ${WEB}/loba
npm install
cd ${DIR}

# Cleanup
ln -sf ${OPT}/openresty/nginx/sbin/nginx ${BIN}/nginx
rm -rf ${OPT}/openresty-*/
rm -rf ${OPT}/MacOSX-*/

# Run the configuration
${BIN}/configure-osx.sh