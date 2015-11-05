#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf

SRC="$RCB_DEC"
DST="$RCB_RST_ROOT"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RESTORE"

function restore_from_backup {
printf "$(date) Restoring $SRC/$DIR/ in $DST/$DIR/\n" > $RCB_LOG_TEMP
if [ ! -d "$DST/$DIR" ]; then
    if ( mkdir -p "$DST/$DIR" >> $RCB_LOG_TEMP 2>&1); then
	printf "$(date) $DST/$DIR created\n" >> $RCB_LOG_TEMP
    else
	printf "$(date) [ERR] Cant create $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] Cant create $DST/$DIR" $RCB_EMAIL
	exit 1
    fi
fi
if ($RSYNC $RSYNC_PARAM $SRC/$DIR/ $DST/$DIR/ >> $RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] $DIR restored in $DST/$DIR\n" >> $RCB_LOG
else
    printf "$(date) [ERR] $DIR failed to restore in $DST/$DIR\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST $DIR failed to restore in $DST/$DIR" $RCB_EMAIL
    exit 1
fi
}

function restore_from_meta {
    # create empty directories
    printf "$(date) Creating empty directories in $DST/$DIR\n" > $RCB_LOG_TEMP
    if (cd  $DST/$DIR; $TAR xvf $SRC/$DIR/$RCB_EMPTYDIRS_TAR >> $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] Empty dirs created in $DST/$DIR\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to create empty dirs in $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST failed to create empty dirs in $DST/$DIR" $RCB_EMAIL
	exit 1
    fi
    # create links
    printf "$(date) Creating links in $DST/$DIR\n" > $RCB_LOG_TEMP
    if (cd  $DST/$DIR; $TAR xvf $SRC/$DIR/$RCB_LINKS_TAR >> $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] Links created in $DST/$DIR\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to create links in $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Failed to create links in  $DST/$DIR" $RCB_EMAIL
	exit 1
    fi
    # restore mode, ownership and time
    printf "$(date) Restoring mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR\n" > $RCB_LOG_TEMP
    if ($MTREE -U -p $DST/$DIR -f $SRC/$DIR/$MTREE_SPEC >> $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] mtree restored from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Failed to restore mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST Failed to restore mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR" $RCB_EMAIL
    fi
}

function restore_compare {
    printf "$(date) diff $SRC/$DIR/ and $DST/$DIR/ started\n" > $RCB_LOG_TEMP
    if ($RSYNC --dry-run --checksum --exclude-from=$RCB_META/$DIR/$RCB_SPECIALS -ahv $SRC/$DIR/ $DST/$DIR/ >> $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] diff $SRC/$DIR/ and $DST/$DIR/ finished\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] diff $SRC/$DIR/ and $DST/$DIR/ failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST diff $SRC/$DIR/ and $DST/$DIR/ failed" $RCB_EMAIL
    fi
}
# TODO: check RCB_LOG_TEMP

printf "$(date) [OK] *** Restoring data from $SRC started\n" >> $RCB_LOG
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
