#!/bin/bash

KIBANA_VERSION=${CONFIG_kibana_version:-"4.3.0"}

USER=kibana
GROUP=kibana
TARGET=/home/${USER}/kibana

addgroup --system ${GROUP}
adduser --system --shell /bin/bash --disabled-password --ingroup ${GROUP} ${USER}
usermod -a -G adm ${USER}

echo "Installing..."

su - ${USER} -s /bin/bash -c "wget -q 'https://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz' && tar xzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz && rm -rf kibana && ln -s kibana-${KIBANA_VERSION}-linux-x64 kibana && rm kibana-${KIBANA_VERSION}-linux-x64.tar.gz"

su - ${USER} -s /bin/bash -c "./kibana/bin/kibana plugin --install elastic/sense"

echo "Configuring..."

mkdir /var/log/kibana/
chown ${USER}:${GROUP} /var/log/kibana
chmod 0755 /var/log/kibana

cat << EOF > /etc/init.d/kibana
#!/bin/sh
### BEGIN INIT INFO
# Provides:          kibana
# Required-Start:    \$remote_fs \$syslog \$network
# Required-Stop:     \$remote_fs \$syslog \$network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start kibana at boot time
# Description:       Enable service kibaba.
### END INIT INFO
COMMAND="\$1"
shift
KIBANA="${TARGET}/bin/kibana"
JOB="\${KIBANA} -e http://localhost:9200 1>&2 >> /var/log/kibana/kibana.log"
case \$COMMAND in
    start)
        /bin/su - ${USER} -s /bin/bash -c "\$JOB &"
        ;;
    stop)
        /usr/bin/pkill -u ${USER}
        ;;
    status)
        pid=\$(/usr/bin/pgrep -u ${USER})
        if [ "x\$pid" = "x" ]
        then
            echo "stopped"
        else
            echo "running with pid \$pid"
        fi
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

chown root:root /etc/init.d/kibana
chmod +x /etc/init.d/kibana

update-rc.d kibana defaults
update-rc.d kibana enable
#update-rc.d kibana disable

service kibana start
#service kibana stop
