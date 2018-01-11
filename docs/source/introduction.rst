Introduction
============

`RCB (Rsync-Crypto-Backup) <https://github.com/vbotka/rcb>`_ is a set of scripts that:

* Create local backup with `rsnapshot <http://rsnapshot.org/>`_
* Encrypt the local backup with `rsyncrypto <https://rsyncrypto.lingnu.com/>`_
* Sync encrypted backup to the remote server with `rsync <https://rsync.samba.org/>`_
* Restore the backup and
* Compare the restored data with the origin

`Rsyncrypto <https://rsyncrypto.lingnu.com/>`_ ensures that doing rsync to synchronize the encrypted files to another machine will have only a small impact on rsync's efficiency.

Installation and configuration tested with Ansible role https://galaxy.ansible.com/vbotka/rcb/ .
