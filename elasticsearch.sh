#!/bin/bash

ES_VERSION=${CONFIG_elasticsearch_version:-"2.x"}

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

echo "deb http://packages.elastic.co/elasticsearch/${ES_VERSION}/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list
apt-get update

apt-get install -y elasticsearch

# https://github.com/jprante/elasticsearch-index-termlist
#cd /usr/share/elasticsearch
#./bin/plugin --install jprante/elasticsearch-index-termlist
#./bin/plugin --install index-termlist --url http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-index-termlist/1.4.4.0/elasticsearch-index-termlist-1.4.4.0-plugin.zip
#cd -

update-rc.d elasticsearch defaults 95 10
#update-rc.d elasticsearch disable
update-rc.d elasticsearch enable

service elasticsearch start
#service elasticsearch stop
