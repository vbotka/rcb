RCB (Rsync-Crypto-Backup) is a set of scripts that

* create local backup with rsnapshot
* encrypt the local backup with rsyncrypto
* store it in the remote server with rsync
* restore the backup and compare with the origin

Rsyncrypto ensures that doing rsync to synchronize the encrypted files
to another machine will have only a small impact on rsync's
efficiency.

RCB is licensed under BSD 2-clause “Simplified” License.
