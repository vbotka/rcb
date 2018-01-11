RCB (Rsync-Crypto-Backup)
=========================
[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html) ![Build Status](https://readthedocs.org/projects/rcb/badge/?version=latest)

RCB is a set of scripts that:

* Create local backup with *rsnapshot*
* Encrypt the local backup with *rsyncrypto*
* Sync encrypted backup to the remote server with *rsync*
* Restore the backup and compare the restored data with the origin

[Rsyncrypto](http://rsyncrypto.lingnu.com/) ensures that doing rsync to synchronize the encrypted files
to another machine will have only a small impact on rsync's efficiency.

Installation and configuration tested with https://galaxy.ansible.com/vbotka/rcb/ version 0.2.0 (client Ubuntu 17.04, server FreeBSD 10.3)

Documentation is available at [ReadTheDoc](http://rcb.readthedocs.io/).
