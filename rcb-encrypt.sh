#!/usr/local/bin/bash

MY_PATH=`dirname "$0"`
. $MY_PATH/rcb-functions.sh
read_config

SRC="$RCB_BCK_ROOT/$RCB_BCK_PREFIX"
DST="$RCB_ENC"

printf "$(date) [OK] *** Encryption of backup started\n" >> $RCB_LOG

# directory to store the meta-data
if [ -d "$RCB_META" ]; then
    if ((find  $RCB_META -mindepth 1 -maxdepth 1 -exec rm -r {} \;) > $RCB_LOG_TEMP_ENC 2>&1); then
	printf "$(date) [OK] files in $RCB_META deleted\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Can't delete files in $RCB_META\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] Can't delete files in $RCB_META" $RCB_EMAIL
	exit 1
    fi
else
    if ( mkdir -p $RCB_META >> $RCB_LOG_TEMP_ENC 2>&1); then
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
    if ($MTREE $MTREE_PARAM $SRC/$REMOTE > $RCB_META/$REMOTE/$MTREE_SPEC 2>$RCB_LOG_TEMP_ENC); then
	printf "$(date) [OK] mtree specification stored in $RCB_META/$REMOTE/$MTREE_SPEC\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mtree failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE backup encryption failed on mtree" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
# rsyncrypto does not store empty directories
    if (cd $SRC/$REMOTE; $FIND . -type d -empty > $RCB_META/$REMOTE/$RCB_EMPTYDIRS); then
	printf "$(date) [OK] Empty dirs stored in $RCB_META/$REMOTE/$RCB_EMPTYDIRS\n" >> $RCB_LOG
	if (cd $SRC/$REMOTE; $TAR cpf $RCB_META/$REMOTE/$RCB_EMPTYDIRS_TAR --files-from $RCB_META/$REMOTE/$RCB_EMPTYDIRS); then
	    printf "$(date) [OK] Empty dirs stored in $RCB_META/$REMOTE/$RCB_EMPTYDIRS_TAR\n" >> $RCB_LOG
	else
	    printf "$(date) [ERR] tar empty dirs failed\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	    cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE failed to tar empty dirs" $RCB_EMAIL
	    rm $RCB_LOG_TEMP_ENC
	    exit 1
	fi
    else
	printf "$(date) [ERR] Failed to find empty dirs\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE failed to find empty dirs" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
# rsyncrypto does not store links
    if (cd $SRC/$REMOTE; $FIND . -type l > $RCB_META/$REMOTE/$RCB_LINKS); then
	printf "$(date) [OK] Links stored in $RCB_META/$REMOTE/$RCB_LINKS\n" >> $RCB_LOG
	if (cd $SRC/$REMOTE; $TAR cpf $RCB_META/$REMOTE/$RCB_LINKS_TAR --files-from $RCB_META/$REMOTE/$RCB_LINKS); then
	    printf "$(date) [OK] Links stored in $RCB_META/$REMOTE/$RCB_LINKS_TAR\n" >> $RCB_LOG
	else
	    printf "$(date) [ERR] Failed to tar links\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	    cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE Failed to tar links" $RCB_EMAIL
	    rm $RCB_LOG_TEMP_ENC
	    exit 1
	fi
    else
	printf "$(date) [ERR] Failed to find links\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE Failed to find links" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
# Store special files. These will be excluded in the comparison of
# the restored files with the origin
# PIPES (-type p)
    if (cd $SRC/$REMOTE; $FIND . -type p | sed -e 's/^\.\///' > $RCB_META/$REMOTE/$RCB_SPECIALS); then
	printf "$(date) [OK] Fifo stored in $RCB_META/$REMOTE/$RCB_SPECIALS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to find fifo\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE Failed to find fifo" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
# SOCKETS (-type s)
    if (cd $SRC/$REMOTE; $FIND . -type s | sed -e 's/^\.\///' >> $RCB_META/$REMOTE/$RCB_SPECIALS); then
	printf "$(date) [OK] Sockets stored in $RCB_META/$REMOTE/$RCB_SPECIALS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to find sockets\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE Failed to find sockets" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
# DIGESTS
    if (cd $SRC; $HASHDEEP $HASHDEEP_PARAM_CREATE $REMOTE/ > $RCB_META/$REMOTE/$RCB_DIGESTS); then
	printf "$(date) [OK] Digests stored in $RCB_META/$REMOTE/$RCB_DIGESTS\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to create digets\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
	cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST $REMOTE Failed to create digests" $RCB_EMAIL
	rm $RCB_LOG_TEMP_ENC
	exit 1
    fi
done

printf "$(date) [OK] *** Encryption of $SRC started\n" >> $RCB_LOG
if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_E -r $SRC $DST $RCB_KEYS $RCB_CRT > $RCB_LOG_TEMP_ENC 2>&1); then
    printf "$(date) [OK] *** Encryption of $SRC finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Encryption of $SRC failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC >> $RCB_LOG
    cat $RCB_LOG_TEMP_ENC | $MAIL -s "[ERR] $RCB_HOST Encryption of $SRC failed" $RCB_EMAIL
    rm $RCB_LOG_TEMP_ENC
    exit 1
fi

exit

# EOF
