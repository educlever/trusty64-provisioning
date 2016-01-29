#!/bin/bash

curl -s -L https://github.com/Pyppe/phantomjs2.0-ubuntu14.04x64/raw/master/bin/phantomjs > /usr/local/bin/phantomjs
chmod +x /usr/local/bin/phantomjs
exit

# TROP LONG A COMPILER !!!

# http://phantomjs.org/build.html

# TODO ttf-mscorefonts-installer debconf

#echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections

#apt-get install -y build-essential g++ flex bison gperf ruby perl libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg-dev python libx11-dev libxext-dev ttf-mscorefonts-installer

#git clone --recurse-submodules git://github.com/ariya/phantomjs.git

#cd phantomjs
#./build.py --jobs 1
#cp ./bin/phantomjs /usr/local/bin/
#cd ..
#rm -rf phantomjs/
