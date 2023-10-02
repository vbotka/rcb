Introduction
============

`RCB (Rsync-Crypto-Backup) <https://github.com/vbotka/rcb>`_ is a set of scripts in Bash that:

* Create local backup with `rsnapshot <http://rsnapshot.org/>`_
* Encrypt local backup with `rsyncrypto <https://rsyncrypto.lingnu.com/>`_
* Sync encrypted backup to the backup server with `rsync <https://rsync.samba.org/>`_
* Restore data from the backup, and
* Compare the restored data with the origin

All updates and transfers are incremental. `rsyncrypto
<https://rsyncrypto.lingnu.com/>`_ ensures that doing rsync to
synchronize the encrypted files to another machine will have only a
small impact on rsync's efficiency. Whole RCB project is approximately
500 lines long.

Installation and configuration was tested with Ansible role `vbotka.rcb <https://galaxy.ansible.com/vbotka/rcb/>`_ with FreeBSD backup server and Ubuntu backup clients.

.. note::

   * Use Ansible role `vbotka.rsnapshot
     <https://galaxy.ansible.com/vbotka/rsnapshot/>`_ to install and
     configure *rsnapshot* on the clients.

   * `rsync <https://rsync.samba.org/>`_ must be installed on the
     clients and also on the backup server.

.. warning::

   `rsyncrypto <https://rsyncrypto.lingnu.com/>`_ summary: "A slightly
   reduced strength bulk encryption. In exchange for the reduced
   strength, you get the ability to rsync the encrypted files, so that
   local changes in the plaintext file will result in (relatively)
   local changes to the cyphertext file."

.. seealso::

   * `Is rsyncrypto secure? <https://security.stackexchange.com/questions/271413/is-rsyncrypto-secure>`_
