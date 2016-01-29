#!/bin/bash

DB_DO_REVERSE=${CONFIG_mysql_reverse:-"no"}
DB_BIND_ADDRESS=${CONFIG_mysql_bind_address:-"0.0.0.0"}
DB_NAME=${CONFIG_mysql_db_name:-""}
DB_ROOT_PASSWORD=${CONFIG_mysql_root_password:-"root"}
DB_REMOVE_ROOT_PASSWORD=${CONFIG_mysql_root_remove:-"root"}
DB_USER_NAME=${CONFIG_mysql_user_name:-"vagrant"}
DB_USER_PASSWORD=${CONFIG_mysql_user_password:-"vagrant"}

echo "mariadb-server-5.5 mysql-server/root_password password $DB_ROOT_PASSWORD" | debconf-set-selections
echo "mariadb-server-5.5 mysql-server/root_password_again password $DB_ROOT_PASSWORD" | debconf-set-selections

apt-get install -y mariadb-server
apt-get install -y mariadb-client

service mysql stop

chmod a+rx /var/log/mysql/

sed -i "s#/var/run/mysqld/mysqld.sock#/tmp/mysql.sock#" /etc/mysql/my.cnf

if [ -n $DB_DO_REVERSE ] && [ $DB_DO_REVERSE = 'no' ]
then
    # http://www.vionblog.com/skip-name-resolve-to-speed-up-mysql-and-avoid-problems/
    cat << EOF > /etc/mysql/conf.d/skip-name-resolve.cnf
[mysqld]
skip-name-resolve
EOF
fi

if [ -n $DB_BIND_ADDRESS ]
then
    cat << EOF > /etc/mysql/conf.d/bind-address.cnf
[mysqld]
bind-address = $DB_BIND_ADDRESS
EOF
fi

service mysql start

echo "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER_NAME'@'%' IDENTIFIED BY '$DB_USER_PASSWORD' WITH GRANT OPTION" | mysql -uroot -p$DB_ROOT_PASSWORD mysql

mysqladmin -p$DB_ROOT_PASSWORD flush-privileges

if [ -n $DB_NAME ]
then
    echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci" | mysql -uroot -p$DB_ROOT_PASSWORD
fi

if [ -n $DB_REMOVE_ROOT_PASSWORD ] && [ $DB_REMOVE_ROOT_PASSWORD = 'yes' ]
then
    mysql -uroot -p$DB_ROOT_PASSWORD -e "SET PASSWORD = PASSWORD('');"
fi

