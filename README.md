RCB (Rsync-Crypto-Backup)
=========================
![license](https://img.shields.io/badge/license-BSD-red.svg)

RCB is a set of scripts that:

* create local backup with *rsnapshot*
* encrypt the local backup with *rsyncrypto*
* sync encrypted backup to the remote server with *rsync*
* restore the backup and compare the restored data with the origin

[Rsyncrypto](http://rsyncrypto.lingnu.com/) ensures that doing rsync to synchronize the encrypted files
to another machine will have only a small impact on rsync's efficiency.

Installation and configuration tested with https://galaxy.ansible.com/vbotka/ansible-rcb/
