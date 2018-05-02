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

Installation and configuration tested with [Ansible role](https://galaxy.ansible.com/vbotka/rcb/) (client Ubuntu 18.04, server FreeBSD 10.3).

Documentation is available at [ReadTheDoc](http://rcb.readthedocs.io/).

References
----------
* [Rsyncrypto project](https://sourceforge.net/projects/rsyncrypto/)
* [Efficient rsyncrypto hides remote sync data](https://www.linux.com/news/efficient-rsyncrypto-hides-remote-sync-data)
* [Why does rsyncrypto require a public key during decryption?](https://crypto.stackexchange.com/questions/26301/why-does-rsyncrypto-require-a-public-key-during-decryption)
