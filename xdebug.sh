#!/bin/bash

# https://chrome.google.com/webstore/detail/xdebug-helper/eadndfjplgieldjbigjakmdgkmoaaaoc
# chrome-extension:// settings phpstorm

# http://www.dragonbe.com/2015/12/installing-php-7-with-xdebug-apache-and.html
# http://blog.shaharia.com/how-to-enable-xdebug-in-nginx/

XDEBUG_VERSION=${CONFIG_xdebug_version:-"2.4.0rc3"}

#apt-get install -y php5-dev
apt-get install -y build-essential autoconf automake libtool bison re2c

PHP_CONFIG=$(which php-config)

curl -sL http://xdebug.org/files/xdebug-${XDEBUG_VERSION}.tgz > xdebug-${XDEBUG_VERSION}.tgz

tar xzf xdebug-${XDEBUG_VERSION}.tgz
rm xdebug-${XDEBUG_VERSION}.tgz
rm package.xml

REAL=$( ls | grep -i xdebug-${XDEBUG_VERSION} )

cd ${REAL}

$(which phpize)

./configure --enable-xdebug --with-php-config=${PHP_CONFIG}

make

PHP_EXTENSION_DIR=$(${PHP_CONFIG} --extension-dir)

cp modules/xdebug.so ${PHP_EXTENSION_DIR}/

cd -

rm -rf ${REAL}

for PHP_INI in $(find /etc/ /usr/local/ -name "php.ini"|grep -v cli)
do
    if [ -z "$(grep xdebug ${PHP_INI})" ];
    then
        cat << EOF >> ${PHP_INI}

[xdebug]
zend_extension=${PHP_EXTENSION_DIR}/xdebug.so
xdebug.remote_port=9000
xdebug.remote_enable=On
xdebug.remote_connect_back=On
xdebug.remote_log=/var/log/xdebug.log
EOF
    fi
done

if [ -n "$(initctl list | grep php5 | grep running)" ]
then
    service php5-fpm restart
fi

if [ -n "$(initctl list | grep php7 | grep running)" ]
then
    service php7-fpm restart
fi
