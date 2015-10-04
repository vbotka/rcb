#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

SRC="$RCB_ENCR"
DST="$RCB_DEC"
RCB_LOG_TEMP="$RCB_LOG_TEMP_DEC"

printf "$(date) [OK] *** Dencryption from $SRC to $DST started\n" >> $RCB_LOG

if [ -d "$DST" ]; then
    if  (rm -rf $DST/*  >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST/* deleted \n" >> $RCB_LOG
    else
	printf "$(date) [ERR] can't delete $DST/*\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST decryptio of backup failed on deleting $DST/*" $RCB_EMAIL
	rm $RCB_LOG_TEMP
	exit 1
    fi
else
    if  (mkdir -p $DST >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST created \n" >> $RCB_LOG
    else
	printf "$(date) [ERR] can't create $DST\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST mkdir -p $DST failed" $RCB_EMAIL
	rm $RCB_LOG_TEMP
	exit 1
    fi
fi

if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_D -d -r $SRC $DST $RCB_KEYS $RCB_CRT >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Decryption from $SRC to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Decryption from $SRC to $DST finished with error\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Decryption from $SRC to $DST finished with error" $RCB_EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
