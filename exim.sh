#!/bin/bash
apt-get install -y exim4 mailutils

hostname -f > /etc/mailname

cat << EOF > /etc/exim4/update-exim4.conf.conf
dc_eximconfig_configtype='satellite'
dc_other_hostnames=''
dc_local_interfaces='127.0.0.1 ; ::1'
dc_readhost='$(hostname -f)'
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost='smtp.elasticemail.com::2525'
CFILEMODE='644'
dc_use_split_config='true'
dc_hide_mailname='true'
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
EOF

cat << EOF > /etc/exim4/passwd.client
smtp.elasticemail.com:3ce652e6-04e0-4f9d-bda0-12d4951616b6:3ce652e6-04e0-4f9d-bda0-12d4951616b6
smtp25.elasticemail.com:3ce652e6-04e0-4f9d-bda0-12d4951616b6:3ce652e6-04e0-4f9d-bda0-12d4951616b6
EOF
chmod 0640 /etc/exim4/passwd.client
chown root.Debian-exim /etc/exim4/passwd.client

update-exim4.conf
invoke-rc.d exim4 restart
exim4 -qff

echo "Test mail from $(hostname -f)" | mail -s "Test Exim from $(hostname -f)" ${CONFIG_exim_test_email:-"tech@maxicours.com"}


# http://bradthemad.org/tech/notes/exim_cheatsheet.php

# pour lister les mails frozen
# exiqgrep -z -i

# pour remettre les mails frozen dans le circuit d'émission
# exiqgrep -z -i | xargs exim -Mt

# pour éliminer les mails frozen
# exiqgrep -z -i | xargs exim -Mrm

# pour afficher la queue par domaine
# exim -bp | exiqsumm
