#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

SRC="$RCB_DEC"
DST="$RCB_RST_ROOT"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RESTORE"

function restore_from_backup {
printf "$(date) [OK] Restore $SRC/$DIR/ to $DST/$DIR/ started\n" >> $RCB_LOG
if [ ! -d "$DST/$DIR" ]; then
    if ( mkdir -p $DST/$DIR >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST/$DIR created\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Can't create $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] Restore from backup failed on mkdir $DST/$DIR" $RCB_EMAIL
	exit 1
    fi
fi
if ($RSYNC $RSYNC_PARAM $SRC/$DIR/ $DST/$DIR/ >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] $DIR restored to $DST/$DIR\n" >> $RCB_LOG
else
    printf "$(date) [ERR] $DIR restore to $DST/$DIR failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST $DIR restore to $DST/$DIR failed" $RCB_EMAIL
    exit 1
fi
}

function restore_from_meta {
    # create empty directories
    printf "$(date) Creating empty directories in $DST\n" >$RCB_LOG_TEMP
    for i in $(cat $SRC/$DIR/$RCB_EMPTYDIRS); do
	if (mkdir -p $DST/$DIR/$i >>$RCB_LOG_TEMP 2>&1); then
	    printf "$(date) [OK] $DST/$DIR/$i created\n" >> $RCB_LOG_TEMP
	else
	    printf "$(date) [ERR] mkdir -p $DST/$DIR/$i failed\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP > $RCB_LOG
	    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST mkdir -p $DST/$DIR/$i failed\n" $RCB_EMAIL
	    exit 1
	fi
    done
    # create links
    printf "$(date) [OK] Creating links in $DST/$DIR\n" >$RCB_LOG_TEMP
    if (cd  $DST/$DIR; $TAR xvf $SRC/$DIR/$RCB_LINKS_TAR >>$RCB_LOG_TEMP 2>&1); then
	    printf "$(date) [OK] Links in $DST/$DIR created\n" >> $RCB_LOG_TEMP
	else
	    printf "$(date) [ERR] Links in $DST/$DIR failed\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP > $RCB_LOG
	    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Links in $DST/$DIR failed" $RCB_EMAIL
	    exit 1
	fi

    # restore mode, ownership and time
    # printf "$MTREE -U -p $DST/$DIR -f $SRC/$DIR/$MTREE_SPEC\n" >> $RCB_LOG
    if ($MTREE -U -p $DST/$DIR -f $SRC/$DIR/$MTREE_SPEC >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] mtree applied from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP > $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR failed" $RCB_EMAIL
    fi
}

function restore_compare {
    printf "$(date) [OK] diff $SRC/$DIR/ and $DST/$DIR/ started\n" >> $RCB_LOG
    if ($RSYNC --dry-run --exclude-from=$RCB_META/$DIR/$RCB_SPECIALS -ahv $SRC/$DIR/ $DST/$DIR/ >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] diff $SRC/$DIR/ and $DST/$DIR/ finished\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] diff $SRC/$DIR/ and $DST/$DIR/ failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP > $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST diff $SRC/$DIR/ and $DST/$DIR/ failed" $RCB_EMAIL
    fi
}
# TODO: check RCB_LOG_TEMP


printf "$(date) [OK] *** Restore from $SRC started\n" >> $RCB_LOG
for DIR in $(ls -1 $SRC); do
    SRC="$RCB_DEC"
    restore_from_backup
    SRC="$RCB_META"
    restore_from_meta
    SRC="$RCB_BCK_ROOT/$RCB_BCK_PREFIX"
    restore_compare
done

SRC="$RCB_BCK_ROOT/$RCB_BCK_PREFIX"
printf "$(date) [OK] *** $SRC restored in $DST\n" >> $RCB_LOG

exit
