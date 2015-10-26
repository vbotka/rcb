#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf
SRC="$BCK_USER@$BCK_HOST:$BCK_DST"
DST="$RCB_ENCR"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RSYNC"

# Optionaly dont rsync. Link the origin instead.
# cd $RCB_BCK_ROOT
# ln -s $RCB_ENC enc.restored
# printf "$(date) [OK] *** Link from $RCB_BCK_ROOT/enc.restored to $RCB_ENC created\n" >> $RCB_LOG
# exit 0

printf "$(date) [OK] *** Rsync from $SRC/ to $DST started\n" >> $RCB_LOG

if ($RSYNC $RSYNC_PARAM -e ssh $SRC/ $DST >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Rsync from $SRC/ to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] Rsync from $SRC/ to $DST failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Rsync from $SRC/ to $DST failed" $RCB_EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
