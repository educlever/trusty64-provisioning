#!/bin/bash

apt-get install -y build-essential autoconf automake libtool bison re2c

git clone --recursive git://github.com/apiaryio/drafter.git
cd drafter
./configure
make drafter
make install
cd -
rm -rf drafter
