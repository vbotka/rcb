#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf
SRC="$RCB_ENC"
DST="$BCK_USER@$BCK_HOST:$BCK_DST"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RSYNC"

printf "$(date) [OK] *** Rsync from $SRC/ to $DST started\n" >> $RCB_LOG

if [ $RSYNC_INCLUDE_FROM == "true" ]; then
    RSYNC_PARAM="$RSYNC_INCLUDE_FROM_FILE $RSYNC_PARAM"
    printf "$(date) [OK] $RSYNC_INCLUDE_FROM_FILE\n" >> $RCB_LOG
fi

if [ $RSYNC_StrictHostKeyChecking == "false" ]; then
    export RSYNC_RSH="$RSYNC_StrictHostKeyChecking_No"
    printf "$(date) [OK] RSYNC_RSH: $RSYNC_RSH\n" >> $RCB_LOG
else
    export RSYNC_RSH="$RSYNC_StrictHostKeyChecking_Yes"
    printf "$(date) [OK] RSYNC_RSH: $RSYNC_RSH\n" >> $RCB_LOG
fi

if ($RSYNC $RSYNC_PARAM $SRC/ $DST > $RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Rsync from $SRC/ to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] Rsync from $SRC/ to $DST failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Rsync from $SRC/ to $DST failed" $RCB_EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
