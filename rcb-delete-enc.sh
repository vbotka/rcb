#!/usr/local/bin/bash

MY_PATH=`dirname "$0"`
. $MY_PATH/rcb-functions.sh
read_config

function rcb_delete {
    if (rm $RCB_PAR1 $RCB_PAR2 >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $RCB_PAR2 deleted\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Cant delete $RCB_PAR2\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Cant delete $RCB_PAR2" $RCB_EMAIL
	rm $RCB_LOG_TEMP
	exit 1
    fi
    }

printf "$(date) [OK] *** Delete encrypted data, meta, keys and names started\n" >> $RCB_LOG
RCB_PAR1="-rf"
RCB_PAR2="$RCB_ENC"
rcb_delete
RCB_PAR1="-rf"
RCB_PAR2="$RCB_META"
rcb_delete
RCB_PAR1="-rf"
RCB_PAR2="$RCB_KEYS"
rcb_delete
RCB_PAR1="-f"
RCB_PAR2="$RCB_NAMES"
rcb_delete
printf "$(date) [OK] *** Encrypted data, meta, keys and names deleted\n" >> $RCB_LOG

exit

# EOF
