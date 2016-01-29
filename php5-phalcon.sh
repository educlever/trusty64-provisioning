#!/bin/bash

yes '' | apt-add-repository ppa:phalcon/stable
apt-get update
apt-get install -y php5-phalcon

if [ -n "$(initctl list | grep php5 | grep running)" ]
then
    service php5-fpm restart
fi

if [ -n "$(initctl list | grep php7 | grep running)" ]
then
    service php7-fpm restart
fi

