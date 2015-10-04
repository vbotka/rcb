#!/usr/local/bin/bash

source /usr/local/etc/rcb.conf
SRC="$RCB_DEC/$RCB_HOST/snapshots/hourly.0"
DST="$RCB_RST_ROOT"
RCB_LOG_TEMP="$RCB_LOG_TEMP_RESTORE"

function restore_from_backup {
printf "$(date) [OK] Restore $SRC/$DIR/ to $DST/$DIR/ started\n" >> $RCB_LOG
if [ ! -d "$DST/$DIR" ]; then
    if ( mkdir -p $DST/$DIR >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST/$DIR created\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Can't create $DST/$DIR\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] Restore from backup failed on mkdir $DST/$DIR" $EMAIL
	exit 1
    fi
fi
if ($RSYNC $RSYNC_PARAM $SRC/$DIR/ $DST/$DIR/ >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] $DIR restored to $DST/$DIR\n" >> $RCB_LOG
else
    printf "$(date) [ERR] $DIR restore to $DST/$DIR failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST $DIR restore to $DST/$DIR failed" $EMAIL
    exit 1
fi
}

function restore_from_meta {
    # create empty directories
    printf "$(date) Creating empty directories in $DST\n" >$RCB_LOG_TEMP
    for i in $(cat $SRC/$DIR/$EMPTYDIRS); do
	if (mkdir -p $DST/$i >>$RCB_LOG_TEMP 2>&1); then
	    printf "$(date) [OK] $DST/$i created\n" >> $RCB_LOG_TEMP
	else
	    printf "$(date) [ERR] mkdir -p $DST/$i failed\n" >> $RCB_LOG
	    cat $RCB_LOG_TEMP > $RCB_LOG
	    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST mkdir -p $DST/$i failed\n" $EMAIL
	    exit 1
	fi
    done
    # restore mode, ownership and time
    # printf "$MTREE -U -p $DST/$DIR -f $SRC/$DIR/$MTREE_SPEC\n" >> $RCB_LOG
    if ($MTREE -U -p $DST/$DIR -f $SRC/$DIR/$MTREE_SPEC >$RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] mtree applied from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR failed\n" >> $RCB_LOG
	cat $RCB_LOG_TEMP > $RCB_LOG
	cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST mtree from $SRC/$DIR/$MTREE_SPEC to $DST/$DIR failed\n" $EMAIL
    fi
}

function restore_compare {
printf "$(date) [OK] diff $SRC/$DIR/ and $DST/$DIR/ started\n" >> $RCB_LOG
# printf "$RSYNC --dry-run --exclude-from=$META/$DIR/$LINKS -Hav $SRC/$DIR/ $DST/$DIR/\n" >$RCB_LOG_TEMP
# TODO: fifo and sockets not excluded
# TODO: links exclude-from doesnt work
# TODO: check RCB_LOG_TEMP fpr pthers
if ($RSYNC --dry-run --exclude-from=$RCB_META/$DIR/$LINKS -ahv $SRC/$DIR/ $DST/$DIR/ >$RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] diff $SRC/$DIR/ and $DST/$DIR/ finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] diff $SRC/$DIR/ and $DST/$DIR/ failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP > $RCB_LOG
    cat $RCB_LOG_TEMP | $MAIL -s "[ERR] $RCB_HOST diff $SRC/$DIR/ and $DST/$DIR/ failed" $EMAIL
fi
}

printf "$(date) [OK] *** Restore from $SRC started\n" >> $RCB_LOG
for DIR in $(ls -1 $SRC); do
    SRC="$RCB_DEC/$RCB_HOST/snapshots/hourly.0"
    restore_from_backup
    SRC="$RCB_META"
    restore_from_meta
    SRC="$RCB_BCK_ROOT/$RCB_HOST/snapshots/hourly.0"
    restore_compare
#   SRC=/
#   restore_compare
done
printf "$(date) [OK] *** Restore from $RCB_DEC/$RCB_HOST/snapshots/hourly.0 to $DST finnished\n" >> $RCB_LOG

# /bin/umount $MOUNTPOINT
exit

# if /bin/mountpoint -q $MOUNTPOINT; then
#     printf "*** [OK] $MOUNTPOINT already mounted\n" >> $RCB_LOG
# else    
#     if (/bin/mount -L planb-backup $MOUNTPOINT 2>&1) | (tee $RCB_LOG_TEMP >> $RCB_LOG); then
#	printf "*** [OK] $MOUNTPOINT mounted\n" >> $RCB_LOG
#    else
#	printf "*** [ERR] $MOUNTPOINT mount failed\n" >> $RCB_LOG
#	cat $RCB_LOG_TEMP | mail -s "$MOUNTPOINT mount failed" $EMAIL
#	exit 1
#    fi
# fi
