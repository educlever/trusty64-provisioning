#!/bin/bash

test ! -d /etc/nginx/common && mkdir /etc/nginx/common

cat << EOF > /etc/nginx/common/markdown.conf
location ~ ([^/]+\.md)\$ {
    rewrite ^(.*)\$ /docs/markdown/handler.php?_url=\$1;
}
EOF

service nginx restart
