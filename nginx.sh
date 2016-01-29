#!/bin/bash

apt-get install -y nginx

service nginx restart

test ! -d /etc/nginx/common && mkdir /etc/nginx/common

echo "" >> /etc/nginx/fastcgi_params
echo "fastcgi_param   PATH_INFO  \$fastcgi_path_info;" >> /etc/nginx/fastcgi_params
