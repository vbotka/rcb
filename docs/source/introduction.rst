Introduction
============

:l:`RCB (Rsync-Crypto-Backup)` is a set of scripts in Bash that:

* Create local backup with :l:`rsnapshot`
* Encrypt local backup with :l:`rsyncrypto`
* Sync encrypted backup to the backup server with :l:`rsync`
* Restore data from the backup, and
* Compare the restored data with the origin

All updates and transfers are incremental. :l:`rsyncrypto` ensures
that doing rsync to synchronize the encrypted files to another machine
will have only a small impact on rsync's efficiency. Whole RCB project
is approximately 500 lines long.

Installation and configuration was tested with Ansible role
:l:`vbotka.rcb` with FreeBSD backup server and Ubuntu backup clients.

.. important::

   :l:`rsyncrypto` summary: "A slightly reduced strength bulk
   encryption. In exchange for the reduced strength, you get the
   ability to rsync the encrypted files, so that local changes in the
   plaintext file will result in (relatively) local changes to the
   cyphertext file."

.. seealso::

   * `Is rsyncrypto secure? <https://security.stackexchange.com/questions/271413/is-rsyncrypto-secure>`_
