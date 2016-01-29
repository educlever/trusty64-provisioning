#!/bin/bash

test ! -d /var/www/adminer && mkdir /var/www/adminer

curl -s -L "http://www.adminer.org/latest.php" > /var/www/adminer/index.php
curl -s -L "https://raw.githubusercontent.com/vrana/adminer/master/designs/pappu687/adminer.css" > /var/www/adminer/adminer.css
