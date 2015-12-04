#!/usr/local/bin/bash

# It is possible to decrypt the files with the private key only. To
# proceed the following 3 parameters are needed
# 1. Private key
RCB_KEY="/path/backup.key"
# 2. Path to encrypted files
SRC="/path_encrypted_files"
# 3. Path to decrypted files
DST="/path_to_decrypted_files"

RCB_DEC_MODE="0700"
RCB_LOG_ROOT="/var/log"
RCB_LOG="$RCB_LOG_ROOT/rcb-central.log"
RCB_LOG_TEMP_ROOT="/tmp"
RCB_LOG_TEMP_DEC="$RCB_LOG_TEMP_ROOT/rcb-temp-decrypt.log"
RCB_LOG_TEMP="$RCB_LOG_TEMP_DEC"
SRC_FILEMAP="$SRC/filemap"
RCB_NAMES="$DST/filemap"
DST_FILEMAP_KEYS="$DST/filemap-keys"
GZIP="/usr/local/bin/gzip"
RSYNCRYPTO="/usr/local/bin/rsyncrypto"
RSYNCRYPTO_TRIM_D="3"
RSYNCRYPTO_PARAM_D="--name-encrypt=$RCB_NAMES --gzip=$GZIP --trim=$RSYNCRYPTO_TRIM_D --changed --delete -vv"
RCB_KEYS_DIR="/export/rcb-keys"

printf "$(date) [OK] *** Decryption from $SRC to $DST started\n" >> $RCB_LOG

if [ -d "$DST" ]; then
    if ((find $DST -mindepth 1 -maxdepth 1 -exec rm -r {} \;) > $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] Files in $DST deleted\n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Cant delete files in $DST\n" >> $RCB_LOG
	exit 1
    fi
else
    if (mkdir -p $DST && chmod $RCB_DEC_MODE $DST > $RCB_LOG_TEMP 2>&1); then
	printf "$(date) [OK] $DST created \n" >> $RCB_LOG
    else
	printf "$(date) [ERR] Cant create $DST\n" >> $RCB_LOG
	exit 1
    fi
fi

# Decrypt. First, generate the mapping file
if ($RSYNCRYPTO --decrypt $SRC_FILEMAP $RCB_NAMES $DST_FILEMAP_KEYS $RCB_KEY > $RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] Mapping file decrypted\n" >> $RCB_LOG
else
    printf "$(date) [ERR] Decryption of mapping file failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    exit 1
fi

# Decrypt.
if ($RSYNCRYPTO $RSYNCRYPTO_PARAM_D -d -r $SRC $DST $RCB_KEYS_DIR $RCB_KEY > $RCB_LOG_TEMP 2>&1); then
    printf "$(date) [OK] *** Decryption from $SRC to $DST finished\n" >> $RCB_LOG
else
    printf "$(date) [ERR] *** Decryption from $SRC to $DST failed\n" >> $RCB_LOG
    cat $RCB_LOG_TEMP >> $RCB_LOG
    exit 1
fi

exit
