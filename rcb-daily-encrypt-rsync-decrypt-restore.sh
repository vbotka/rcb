#!/usr/local/bin/bash
rcb-rsnapshot.sh -i=daily
rcb-encrypt.sh
rcb-rsync.sh
rcb-rsync-back.sh
rcb-decrypt.sh
rcb-restore.sh

# EOF
