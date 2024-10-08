# RCB (Rsync-Crypto-Backup)

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)
[![Documentation Status](https://readthedocs.org/projects/rcb/badge/?version=latest)](https://rcb.readthedocs.io/en/latest/?badge=latest)
[![GitHub tag](https://img.shields.io/github/v/tag/vbotka/rcb)](https://github.com/vbotka/rcb/tags)

[Documentation at ReadTheDoc](http://rcb.readthedocs.io/)


RCB is a set of scripts that:

* Create local backup with *rsnapshot*
* Encrypt the local backup with *rsyncrypto*
* Sync encrypted backup to the remote server with *rsync*
* Restore the backup and compare the restored data with the origin

[Rsyncrypto](http://rsyncrypto.lingnu.com/) ensures that doing rsync to synchronize the encrypted files
to another machine will have only a small impact on rsync's efficiency.

Installation and configuration was tested with [Ansible role](https://galaxy.ansible.com/vbotka/rcb/)

Feel free to [share your feedback and report issues](https://github.com/vbotka/rcb/issues).

[Contributions are welcome](https://github.com/firstcontributions/first-contributions).


## Supported platforms

* server: [FreeBSD Supported Production Releases](https://www.freebsd.org/releases/)
* client: [Ubuntu Supported Releases](http://releases.ubuntu.com/)


## References

* [Rsyncrypto project](https://sourceforge.net/projects/rsyncrypto/)
* [Efficient rsyncrypto hides remote sync data](https://www.linux.com/news/efficient-rsyncrypto-hides-remote-sync-data)
* [Why does rsyncrypto require a public key during decryption?](https://crypto.stackexchange.com/questions/26301/why-does-rsyncrypto-require-a-public-key-during-decryption)


## License

[![license](https://img.shields.io/badge/license-BSD-red.svg)](https://www.freebsd.org/doc/en/articles/bsdl-gpl/article.html)


## Author Information

[Vladimir Botka](https://botka.info)
