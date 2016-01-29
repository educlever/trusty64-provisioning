#!/bin/bash

if [ -z "$(which mailcatcher)" ]
then
    apt-get install -y ruby-dev
    apt-get install -y libsqlite3-dev
    gem install mailcatcher
fi

cat << EOF > /etc/init.d/mailcatcher
#!/bin/sh
### BEGIN INIT INFO
# Provides:          mailcatcher
# Required-Start:    \$remote_fs \$syslog \$network
# Required-Stop:     \$remote_fs \$syslog \$network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start mailcatcher at boot time
# Description:       Enable service mailcatcher.
### END INIT INFO
COMMAND="\$1"
if [ -z "\${COMMAND}" ]
then
    COMMAND="help"
else
    shift
fi
NAME="mailcatcher"
DAEMON="/usr/local/bin/\${NAME}"
JOB="\${DAEMON} --http-ip 0.0.0.0 --no-quit -f -v"

case \$COMMAND in
    start)
        ( \$JOB 1>&2 >> /var/log/\${NAME}.log ) &
        ;;
    stop)
        /usr/bin/pkill -f \${DAEMON}
        ;;
    enable)
        for PHP_INI in \$(find /etc/ /usr/local/ -name "php.ini")
        do
            if [ -n "\$(grep catchmail \${PHP_INI})" ]
            then
               echo "already enabled"
            else
                echo "enabling in \${PHP_INI}..."
                grep sendmail_path \${PHP_INI}
                sed -i -E "s#^;sendmail_path.+#sendmail_path = /usr/bin/env \$(which catchmail)#" \${PHP_INI}
                grep sendmail_path \${PHP_INI}
            fi
        done
        if [ -n "\$(initctl list | grep php5 | grep running)" ]
        then
            service php5-fpm restart
        fi

        if [ -n "\$(initctl list | grep php7 | grep running)" ]
        then
            service php7-fpm restart
        fi
    ;;
    disable)
        for PHP_INI in \$(find /etc/ /usr/local/ -name "php.ini")
        do
        if [ -z "\$(grep catchmail \${PHP_INI})" ]
        then
            echo "already disabled"
        else
            echo "disabling in \${PHP_INI}..."
            grep sendmail_path \${PHP_INI}
            sed -i -E 's#^sendmail_path.+#;sendmail_path=#' \${PHP_INI}
            grep sendmail_path \${PHP_INI}
        fi
        done
        if [ -n "\$(initctl list | grep php5 | grep running)" ]
        then
            service php5-fpm restart
        fi

        if [ -n "\$(initctl list | grep php7 | grep running)" ]
        then
            service php7-fpm restart
        fi
    ;;
    status)
        pid=\$(/usr/bin/pgrep -f \${DAEMON})
        if [ "x\$pid" = "x" ]
        then
            echo "stopped"
        else
            echo "running with pid \$pid"
        fi
        if [ -n "\$(grep catchmail \${PHP_INI})" ]
        then
            echo "enabled in \${PHP_INI}"
        else
            echo "disabled in \${PHP_INI}"
        fi
        ;;
    restart)
        \$0 stop
        \$0 start
        ;;
    *)
    echo "Usage: \$(basename \$0) {start|stop|restart|enable|disable|status}"
    exit 3
    ;;
esac
EOF

chmod +x /etc/init.d/mailcatcher

update-rc.d mailcatcher defaults

service mailcatcher start
service mailcatcher enable