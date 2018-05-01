#!/usr/local/bin/bash

MY_PATH=`dirname "$0"`
. $MY_PATH/rcb-functions.sh
read_config

echo "rcb-test-mail.sh started" |  $MAIL -s "rcb-test-mail.sh" $RCB_EMAIL

# EOF
