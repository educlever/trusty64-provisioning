#!/bin/bash

PHP_USER="www-data"
PHP_GROUP="www-data"

apt-get install -y php-config
apt-get install -y php5-cli
apt-get install -y php5-fpm

apt-get install -y libevent-dev libpcre3-dev libcurl4-openssl-dev
apt-get install -y php5-cli php5-dev php-pear
apt-get install -y php5-curl php5-json php5-ldap php5-mysql php5-oauth php5-mcrypt php5-xdebug
apt-get install -y php5-recode php5-sqlite php5-tidy php5-xmlrpc
apt-get install -y php5-imagick php5-imap php5-intl php5-svn
apt-get install -y php5-rrd php5-librdf php5-exactimage php5-gd
apt-get install -y php5-readline php5-mongo php5-redis

php5enmod mcrypt

apt-get install -y libyaml-dev
yes '' | pecl install -o yaml
cat << EOL > /etc/php5/mods-available/yaml.ini
; configuration for php yaml module
; priority=20
extension=yaml.so
EOL
php5enmod yaml

pecl channel-update pecl.php.net

yes '' | pecl install -o raphf
cat << EOL > /etc/php5/mods-available/raphf.ini
; configuration for php raphf module
; priority=20
extension=raphf.so
EOL
php5enmod raphf

yes '' | pecl install -o propro
cat << EOL > /etc/php5/mods-available/propro.ini
; configuration for php propro module
; priority=20
extension=propro.so
EOL
php5enmod propro

# do not use version 2.* !
#yes '' | pecl install -o pecl_http
yes '' | pecl install -o pecl_http-1.7.6
cat << EOL > /etc/php5/mods-available/http.ini
; configuration for php http module
; priority=30
extension=http.so
EOL
php5enmod http

apt-get install php5-xsl

chmod a+w /var/lib/php5

for PHP_INI in $(find /etc/ /usr/local/ -name "php.ini")
do
    sed -i -E "s#(^.*mysql.*\.default_socket).+#\1 = /tmp/mysql.sock#" ${PHP_INI}
done

cat << EOF > /etc/php5/fpm/pool.d/www.conf
[php5]
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

service php5-fpm restart

cat << EOF > /etc/nginx/common/php.conf
location ~ [^/]\.php(/|\$) {
  fastcgi_pass unix:/tmp/fastcgi.socket;
  fastcgi_index index.php;

  include fastcgi_params;
  fastcgi_split_path_info ^(.+?\.php)(/.*)\$;

  if (!-f \$document_root\$fastcgi_script_name) {
      return 404;
  }

  fastcgi_param PATH_INFO       \$fastcgi_path_info;
  fastcgi_param PATH_TRANSLATED \$document_root\$fastcgi_path_info;
  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
}
EOF

service nginx restart
