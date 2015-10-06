#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf
echo "rcb-test-mail.sh started" |  $MAIL -s "rcb-test-mail.sh" $RCB_EMAIL
