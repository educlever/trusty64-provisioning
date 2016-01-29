#!/bin/bash

PHP_VERSION=${CONFIG_php_version:-"7.0.0"}
PHP_USER="www-data"
PHP_GROUP="www-data"

apt-get install -y php5-fpm

apt-get install -y libxml2-dev
apt-get install -y libbz2-dev
apt-get install -y libenchant-dev
apt-get install -y libjpeg-dev
apt-get install -y libpng-dev
apt-get install -y libc-client2007e-dev
apt-get install -y libicu-dev
apt-get install -y libldap2-dev
apt-get install -y libmcrypt-dev
apt-get install -y libreadline-dev
apt-get install -y libtidy-dev
apt-get install -y libxslt1-dev
apt-get install -y libcurl4-openssl-dev

apt-get install -y build-essential autoconf automake libtool bison re2c

#apt-get install -y libfreetype6-dev
#apt-get install -y libmysqlclient-dev
#apt-get install -y libt1-dev
#apt-get install -y libgmp-dev
#apt-get install -y libpspell-dev
#apt-get install -y libpcre3-dev

if [ ! -d php-${PHP_VERSION} ]
then

    curl -sL http://fr2.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror > php-${PHP_VERSION}.tar.gz

    tar xzf php-${PHP_VERSION}.tar.gz
    rm -rf php-${PHP_VERSION}.tar.gz

    cd php-${PHP_VERSION}
    ./configure \
        --enable-fpm --with-fpm-user=${PHP_USER} --with-fpm-group=${PHP_GROUP} \
        --with-openssl \
        --with-pcre-regex \
        --with-kerberos \
        --with-zlib \
        --with-bz2 \
        --with-curl \
        --with-enchant \
        --enable-exif \
        --enable-ftp \
        --with-gd \
        --with-gettext \
        --with-imap \
        --with-imap \
        --with-imap-ssl \
        --enable-intl \
        --enable-mbstring \
        --with-mcrypt \
        --enable-pcntl \
        --with-pdo-mysql \
        --with-readline \
        --enable-soap \
        --enable-sockets \
        --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --with-tidy \
        --with-xsl \
        --enable-zip \
        --with-pear

    make
    make install

    cp php.ini-development /usr/local/lib/php.ini

    cd -

    if [ $CONFIG_php_preservesources != 'yes' ]
    then
        rm -rf php-${PHP_VERSION}
    fi

fi

cat << EOF > /etc/php5/fpm/pool.d/www.conf
[php7]
user = ${PHP_USER}
group = ${PHP_GROUP}
listen = /tmp/fastcgi.socket
listen.owner = ${PHP_USER}
listen.group = ${PHP_GROUP}
pm = dynamic
pm.max_children = 10
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
EOF

update-rc.d php5-fpm disable
service php5-fpm stop

cp /usr/lib/php5/php5-fpm-checkconf /usr/local/lib/php/php7-fpm-checkconf
sed -i "s#/usr/sbin/php5-fpm#/usr/local/sbin/php-fpm#" /usr/local/lib/php/php7-fpm-checkconf

cp /etc/init/php5-fpm.conf /etc/init/php7-fpm.conf
sed -i "s#/usr/lib/php5/php5-fpm-checkconf#/usr/local/lib/php/php7-fpm-checkconf#" /etc/init/php7-fpm.conf
sed -i "s#/usr/sbin/php5-fpm#/usr/local/sbin/php-fpm#" /etc/init/php7-fpm.conf
mv /etc/init/php5-fpm.conf /etc/init/php5-fpm.conf-disabled

cp /etc/init.d/php5-fpm /etc/init.d/php7-fpm
sed -i "s#/usr/lib/php5/php5-fpm-checkconf#/usr/local/lib/php/php7-fpm-checkconf#" /etc/init.d/php7-fpm
sed -i "s#DAEMON=/usr/sbin/\$NAME#DAEMON=/usr/local/sbin/php-fpm#" /etc/init.d/php7-fpm
sed -i "s#php5-fpm#php7-fpm#" /etc/init.d/php7-fpm

update-rc.d php7-fpm defaults

service php7-fpm start

cat << EOF > /etc/nginx/common/php.conf
location ~ [^/]\.php(/|\$) {

  fastcgi_split_path_info ^(.+?\.php)(/.*)\$;

  fastcgi_pass unix:/tmp/fastcgi.socket;

  fastcgi_param SCRIPT_FILENAME \$fastcgi_script_name;

  fastcgi_index index.php;

  include fastcgi_params;
}
EOF

service nginx restart
