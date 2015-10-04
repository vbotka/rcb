#!/usr/local/bin/bash
/root/bin/rcb-rsnapshot.sh -i=daily
/root/bin/rcb-encrypt.sh
/root/bin/rcb-rsync.sh
/root/bin/rcb-rsync-back.sh
/root/bin/rcb-decrypt.sh
/root/bin/rcb-restore.sh
