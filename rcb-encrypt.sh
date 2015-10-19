#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

SRC="$RCB_BCK_ROOT/$RCB_HOST/snapshots/hourly.0"
DST="$RCB_ENC"

printf "$(date) [OK] *** Encryption of backup started\n" >> $RCB_LOG

# directory to store the meta-data
if [ -d "$RCB_META" ]; then
    if ( rm -r $(find  $RCB_META -mindepth 1 -maxdepth 1) >$RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] files in $RCB_META deleted\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Can't delete files in $RCB_META\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] Can't delete files in $RCB_META" $RCB_EMAIL
	exit 1
    fi
else
    if ( mkdir -p $RCB_META >$RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] $RCB_META created\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mkdir $RCB_META failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] mkdir $RCB_META failed" $RCB_EMAIL
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
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST backup encryption failed on creating $RCB_META/$REMOTE" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto doesnt store ownership and mode of the files
    if ($MTREE $MTREE_PARAM -p $SRC/$REMOTE > $RCB_META/$REMOTE/$MTREE_SPEC 2>$RCB_LOG_TEMP_ENC); then
	printf "$(date) [OK] mtree specification stored in $RCB_META/$REMOTE/$MTREE_SPEC\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mtree failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup encryption failed on mtree" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store empty directories
    if (cd $SRC; $FIND . -type d -empty | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$RCB_EMPTYDIRS); then
	printf "$(date) [OK] empty directories stored in $RCB_META/$REMOTE/$RCB_EMPTYDIRS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find empty directories failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding empty dirs" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store links
    if (cd $SRC; $FIND . -type l | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$RCB_LINKS); then
	printf "$(date) [OK] links stored in $RCB_META/$REMOTE/$RCB_LINKS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find links failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding links" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store fifo
    if (cd $SRC; $FIND . -type p | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$RCB_FIFO); then
	printf "$(date) [OK] fifo stored in $RCB_META/$REMOTE/$RCB_FIFO\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find fifo failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup failed on finding fifo" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
    # rsyncrypto does not store sockets
    if (cd $SRC; $FIND . -type s | sed "s|^\./||" | sort > $RCB_META/$REMOTE/$RCB_SOCKS); then
	printf "$(date) [OK] sockets stored in $RCB_META/$REMOTE/$RCB_SOCKS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] find sockets failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE find sockets failed" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
done

# printf "$RSYNCRYPTO $RSYNCRYPTO_PARAM_E -r $SRC $DST $RCB_KEYS $RCB_CRT\n" >> $RCB_LOG
if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_E -r $SRC $DST $RCB_KEYS $RCB_CRT >$RCB_LOG_TEMP_ENC 2>&1); then
    printf "$(date) [OK] *** Encryption of $SRC finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Encryption of $SRC finished with error\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST Encryption of $SRC finished with error" $RCB_EMAIL
    rm $RCB_LOG_TEMP_ENC
    exit 1
fi

exit
