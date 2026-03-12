Introduction
============

`RCB (Rsync-Crypto-Backup)`_ is a set of scripts in Bash that:

* Create local backup with `rsnapshot`_
* Encrypt local backup with `rsyncrypto`_
* Sync encrypted backup to the backup server with `rsync`_
* Restore data from the backup, and
* Compare the restored data with the origin

All updates and transfers are incremental. `rsyncrypto`_ ensures that doing rsync to
synchronize the encrypted files to another machine will have only a small impact on
rsync's efficiency. Whole RCB project is approximately 500 lines long.

Installation and configuration was tested with Ansible role `vbotka.rcb`_ with FreeBSD
backup server and Ubuntu backup clients.

.. important::

   `rsyncrypto`_ summary: "A slightly reduced strength bulk encryption. In exchange for
   the reduced strength, you get the ability to rsync the encrypted files, so that local
   changes in the plaintext file will result in (relatively) local changes to the
   cyphertext file."

.. seealso::

   * `Is rsyncrypto secure?`_


.. _RCB (Rsync-Crypto-Backup): https://github.com/vbotka/rcb/
.. _rsnapshot: https://rsnapshot.org/
.. _rsyncrypto: https://rsyncrypto.lingnu.com/
.. _rsync: https://rsync.samba.org/
.. _vbotka.linux_postinstall: https://galaxy.ansible.com/ui/standalone/roles/vbotka/linux_postinstall/
.. _vbotka.rcb: https://galaxy.ansible.com/ui/standalone/roles/vbotka/rcb/
.. _vbotka.rsnapshot: https://galaxy.ansible.com/ui/standalone/roles/vbotka/rsnapshot/
.. _vbotka.ansible_lib: https://galaxy.ansible.com/ui/standalone/roles/vbotka/ansible_lib/
.. _community.general: https://github.com/ansible-collections/community.general
.. _community.crypto: https://github.com/ansible-collections/community.crypto
.. _Is rsyncrypto secure?: https://security.stackexchange.com/questions/271413/is-rsyncrypto-secure
