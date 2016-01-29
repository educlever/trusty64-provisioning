#!/bin/bash

apt-get install -y graphviz
pear channel-discover pear.phpdoc.org
pear install phpdoc/phpDocumentor
