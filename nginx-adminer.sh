#!/bin/bash

test ! -d /etc/nginx/common && mkdir /etc/nginx/common

cat << EOF > /etc/nginx/common/adminer.conf
location /adminer/ {
      root /var/www/;
      index index.php;
      location ~ [^/]\.php(/|\$) {
          include common/php.conf;
      }
}
EOF

service nginx restart
