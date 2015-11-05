#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

USAGE="$(basename "$0") [-h|--help] [-d|--delete] -- decrypt backup
where:
    -h --help show this help text
    -d --delete already decrypted data, if exists"

DST_DEL="false"
for i in "$@"; do
    case $i in
	-h|--help)
	    echo "$USAGE"
	    exit
	    ;;
	-d|--delete)
	    DST_DEL="true"
	    ;;
	--default)
	    DST_DEL="false"
	    ;;
	*)
	    # unknown option
	    ;;
    esac
done


SRC="$RCB_ENCR"
DST="$RCB_DEC"
RCB_LOG_TEMP="$RCB_LOG_TEMP_DEC"

printf "$(date) [OK] *** Decryption from $SRC to $DST started\n" >> $RCB_LOG

if [ -d "$DST" ]; then
    if [ $DST_DEL == "true" ]; then
	if ((find $DST -mindepth 1 -maxdepth 1 -exec rm -r {} \;) > $RCB_LOG_TEMP_ENC 2>&1); then
	    printf "$(date) [OK] Files in $DST deleted\n" >> $RCB_LOG
	else
	    printf "$(date) [ERR] Cant delete files in $DST\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Cant delete files in $DST" $RCB_EMAIL
	    rm $RCB_LOG_TEMP
	    exit 1
	fi
    fi
else
    if (mkdir -p $DST && chmod $RCB_DEC_MODE $DST > $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST created \n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Cant create $DST\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Cant create $DST" $RCB_EMAIL
	rm $RCB_LOG_TEMP
	exit 1
    fi
fi

if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_D -d -r $SRC $DST $RCB_KEYS $RCB_CRT > $RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Decryption from $SRC to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Decryption from $SRC to $DST failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Decryption from $SRC to $DST failed" $RCB_EMAIL
    rm $RCB_LOG_TEMP
    exit 1
fi

exit
