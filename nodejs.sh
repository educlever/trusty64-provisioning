#!/bin/bash

curl -sL https://deb.nodesource.com/setup | /bin/bash -

apt-get install -y nodejs

npm -g install npm@latest

echo -n "node "
node --version

echo -n "npm "
npm --version
