#!/bin/bash

usermod -a -G adm vagrant

cat << EOF > /home/vagrant/.gitignore_global
*~
.DS_Store
EOF

chown vagrant.vagrant /home/vagrant/.gitignore_global

su vagrant -l -c "git config --global core.excludesfile /home/vagrant/.gitignore_global"
