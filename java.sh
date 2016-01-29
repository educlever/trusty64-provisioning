#!/bin/bash

# apt-get install -y openjdk-7-jre-headless

echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:webupd8team/java
apt-get update
apt-get -y install oracle-java8-installer
