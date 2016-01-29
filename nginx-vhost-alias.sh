#!/bin/bash

test ! -d /etc/nginx/common && mkdir /etc/nginx/common

cat << EOF > /etc/nginx/sites-available/vhost_alias.conf
server {
  listen 80 default;

  server_name ~^(?<website>.+)\.edu\$;

  access_log /var/log/nginx/\$website.access.log;
  #error_log /var/log/nginx/error.log debug;

  root /var/www/\$website/;
  index index.php index.html;

  location / {
	  autoindex on;
	  # http://smotko.si/nginx-static-file-problem/
	  sendfile off;
  }

  include common/*.conf;
}             
EOF

test ! -e /etc/nginx/sites-enabled/vhost_alias.conf && ln -s /etc/nginx/sites-available/vhost_alias.conf /etc/nginx/sites-enabled/vhost_alias.conf
test -e /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-enabled/default

service nginx restart
