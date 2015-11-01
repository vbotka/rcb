#!/bin/bash

source /usr/local/etc/rcb.conf

USAGE="$(basename "$0") [-h|--help] [-l|--link] -- rsync from backup
where:
    -h --help show this help text
    -l --link links the origin directory instead of rsync"

LINK=false
for i in "$@"; do
    case $i in
	-h*|--help*)
	    echo "$USAGE"
	    exit
	    ;;
	-l=*|--link=*)
	    LINK=true
	    ;;
	--default)
	    LINK=false
	    ;;
	*)
	    # unknown option
	    ;;
    esac
done

SRC="$BCK_USER@$BCK_HOST:$BCK_DST"
DST="$RCB_ENCR"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RSYNC"

# Optionaly dont rsync. Link the origin instead.
if [ $LINK ]; then
    if [ -e $RCB_ENCR ]; then
	rm -r $RCB_ENCR
    fi
    ln -s $RCB_ENC $RCB_ENCR
    printf "$(date) [OK] *** Link from $RCB_ENC to $RCB_ENCR created\n" >> $RCB_LOG
    exit 0
fi

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
