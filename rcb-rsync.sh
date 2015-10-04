#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf
SRC="$RCB_ENC"
DST="$BCK_USER@$BCK_HOST:$BCK_DST"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RSYNC"

if [ $RSYNC_INCLUDE_FROM ]; then
    RSYNC_PARAM_LOCAL="$RSYNC_INCLUDE_FROM_FILE $RSYNC_PARAM"
else
    RSYNC_PARAM_LOCAL="$RSYNC_PARAM"
fi

printf "$(date) [OK] *** Rsync from $SRC/ to $DST started\n" >> $RCB_LOG
# printf "$RSYNC $RSYNC_PARAM_LOCAL -e ssh $SRC/ $DST\n" >> $RCB_LOG
if ($RSYNC $RSYNC_PARAM_LOCAL -e ssh $SRC/ $DST >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Rsync from $SRC/ to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] Rsync from $SRC/ to $DST failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Rsync from $SRC/ to $DST failed" $EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
