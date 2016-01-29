#!/bin/bash

DB_ROOT_PASSWORD=${CONFIG_orientdb_root_password:-"root"}
VERSION=${CONFIG_orientdb_version:-"2.0.6"}

USER=orientdb
GROUP=orientdb
TARGET=/home/${USER}/orientdb

addgroup --system ${GROUP}
adduser --system --shell /bin/bash --disabled-password --ingroup ${GROUP} ${USER}
usermod -a -G adm ${USER}

echo "Installing..."

su - ${USER} -s /bin/bash -c "wget -q 'http://www.orientechnologies.com/download.php?email=unknown@unknown.com&file=orientdb-community-${VERSION}.tar.gz&os=linux' -O orientdb-community-${VERSION}.tar.gz && tar xzf orientdb-community-${VERSION}.tar.gz && rm -rf orientdb && ln -s orientdb-community-${VERSION} orientdb && rm orientdb-community-${VERSION}.tar.gz"

echo "Configuring..."

ln -s ${TARGET}/log /var/log/orientdb
chown ${USER}:adm /var/log/orientdb
chmod 0755 /var/log/orientdb

sed -i "s#YOUR_ORIENTDB_INSTALLATION_PATH#${TARGET}#" ${TARGET}/bin/orientdb.sh
sed -i "s#USER_YOU_WANT_ORIENTDB_RUN_WITH#${USER}#" ${TARGET}/bin/orientdb.sh
sed -i -E "s#<user resources=\"\\*\" password=\"[^\"]+\" name=\"root\"/>#<user resources=\"*\" password=\"${DB_ROOT_PASSWORD}\" name=\"root\"/>#" ${TARGET}/config/orientdb-server-config.xml

cat << EOF > /etc/init.d/orientdb
#!/bin/sh
### BEGIN INIT INFO
# Provides:          orientdb
# Required-Start:    \$remote_fs \$syslog \$network
# Required-Stop:     \$remote_fs \$syslog \$network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start orientdb at boot time
# Description:       Enable service orientdb.
### END INIT INFO
COMMAND="\$1"
shift
ORIENTDB="${TARGET}/bin"
JOB="\${ORIENTDB}/orientdb.sh"
case \$COMMAND in
    start)
        ORIENTDB_ROOT_PASSWORD="${DB_ROOT_PASSWORD}"
        \$JOB start
        ;;
    stop)
        \$JOB stop
        ;;
    status)
        \$JOB status
        ;;
    restart)
        \$0 stop
        \$0 start
        ;;
    *)
    echo "Usage: \$(basename \$0) {start|stop|restart|status}"
    exit 3
    ;;
esac
EOF

chown root:root /etc/init.d/orientdb
chmod +x /etc/init.d/orientdb

#update-rc.d orientdb disable
update-rc.d orientdb defaults

service orientdb start
#service orientdb stop
