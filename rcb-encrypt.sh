#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

SRC="$RCB_BCK_ROOT/$RCB_HOST/snapshots/hourly.0"
DST="$RCB_ENC"

printf "$(date) [OK] *** Encryption of backup started\n" >> $RCB_LOG

# directory to store the meta-data
if [ -d "$RCB_META" ]; then
    if ( rm -rf $RCB_META/* >$RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] $RCB_META/* deleted\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Can't delete $RCB_META/*\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] rm $RCB_META/* failed" $EMAIL
	exit 1
    fi
else
    if ( mkdir -p $RCB_META >$RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] $RCB_META created\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mkdir $RCB_META failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] mkdir $RCB_META failed" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
fi

# REMOTE are the directories defined in BACKUP POINTS (3rd parameter)
# of rsnapshot.conf
for REMOTE in $(ls -1 $SRC); do
    if (mkdir $RCB_META/$REMOTE >$RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] $RCB_META/$REMOTE created\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] can't create $RCB_META/$REMOTE\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST backup encryption failed on creating $RCB_META/$REMOTE" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto doesnt store ownership and mode of the files
    if ($MTREE $MTREE_PARAM -p $SRC/$REMOTE > $RCB_META/$REMOTE/$MTREE_SPEC 2>$RCB_LOG_TEMP_ENC); then
	printf "$(date) [OK] mtree specification stored in $RCB_META/$REMOTE/$MTREE_SPEC\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mtree failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup encryption failed on mtree" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store empty directories
    if (cd $SRC; $FIND . -type d -empty 2>$RCB_LOG_TEMP_ENC| sed "s|^\./||" | sort > $RCB_META/$REMOTE/$EMPTYDIRS); then
	printf "$(date) [OK] empty directories stored in $RCB_META/$REMOTE/$EMPTYDIRS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find empty directories failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding empty dirs" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store links
    if (cd $SRC; $FIND . -type l | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$LINKS); then
	printf "$(date) [OK] links stored in $RCB_META/$REMOTE/$LINKS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find links failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding links" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store fifo and sockets
    if (cd $SRC; $FIND . -type ps | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$SPECIALS); then
	printf "$(date) [OK] fifo and sockets stored in $RCB_META/$REMOTE/$SPECIALS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find fifo and sockets failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding fifo and sockets" $EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
done

# printf "$RSYNCRYPTO $RSYNCRYPTO_PARAM_E -r $SRC $DST $KEYS $CRT\n" >> $RCB_LOG
if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_E -r $SRC $DST $KEYS $CRT >$RCB_LOG_TEMP_ENC 2>&1); then
    printf "$(date) [OK] *** Encryption of $SRC finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Encryption of $SRC finished with error\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST Encryption of $SRC finished with error" $EMAIL
    rm $RCB_LOG_TEMP_ENC
    exit 1
fi

exit
