#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

USAGE="$(basename "$0") [-h|--help] [-l|--link] [-d|--delete] -- rsync from backup
where:
    -h --help     show this help text
    -l --link     links the origin directory instead of rsync
    -d --delete   delete the destination defore rsync

LINK="false"
DELETE="false"
for i in "$@"; do
    case $i in
	-h|--help)
	    echo "$USAGE"
	    exit
	    ;;
	-l|--link)
	    LINK="true"
	    ;;
	-d|--delete)
	    DELETE="true"
	    ;;
	--default)
	    LINK="false"
	    DELETE="false"
	    ;;
	*)
	    # unknown option
	    ;;
    esac
done

SRC="$BCK_USER@$BCK_HOST:$BCK_DST"
DST="$RCB_ENCR"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RSYNC"

printf "$(date) [OK] *** Rsync from $SRC/ to $DST (link:$LINK delete:$DELETE) started\n" >> $RCB_LOG

if [ $DELETE == "true" ]; then
    rm -r $DST
    printf "$(date) [OK] $DST deleted\n" >> $RCB_LOG
fi

# Optionaly dont rsync. Link the origin instead.
if [ $LINK == "true" ]; then
    if [ -e $DST ]; then
	rm -r $DST
    fi
    ln -s $RCB_ENC $DST
    printf "$(date) [OK] *** Link from $RCB_ENC to $DST created\n" >> $RCB_LOG
    exit 0
else
    if [ -L $DST ]; then
	unlink $DST
    fi
    if [ ! -e $DST ]; then
	mkdir $DST
	printf "$(date) [OK] $DST created\n" >> $RCB_LOG
    fi
fi

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
