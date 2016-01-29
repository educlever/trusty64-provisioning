#!/bin/bash

echo ${CONFIG_timezone:-"Europe/Paris"} > /etc/timezone
echo ${CONFIG_localtime:-"CET"} > /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

apt-get install -y ntp ntpdate

hwclock -w
