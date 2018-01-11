Scripts
=======

rcb-rsnapshot.sh
----------------

`[rcb-rsnapshot.sh] <https://github.com/vbotka/rcb/blob/master/rcb-rsnapshot.sh>`_

.. code-block:: bash

  > /root/bin/rcb-rsnapshot.sh
  rcb-rsnapshot.sh [-h|--help] [-i|--increment=[hourly,daily,weekly,monthly]] -- rsnapshot backup
  where:
      -h --help show this help text
      -i --increment is one of the options: hourly,daily,weekly or monthly

rcb-encrypt.sh
--------------

`[rcb-encrypt.sh] <https://github.com/vbotka/rcb/blob/master/rcb-encrypt.sh>`_

   1. Delete files in directory $RCB_META. If directory $RCB_META doesn't exist, create it.
   
   2. Create directory $RCB_META/$REMOTE if it doesn't exist. REMOTE are the directories defined in BACKUP POINTS (3rd parameter) of rsnapshot.conf

   3. Store lists of empty directories, links, special files and sockets in the directory $RCB_META/$REMOTE. Create digests in $RCB_META/$REMOTE/$RCB_DIGESTS. Encrtypt $RCB_BCK_ROOT/$RCB_BCK_PREFIX to $RCB_ENC.


rcb-rsync.sh
------------

`[rcb-rsync.sh] <https://github.com/vbotka/rcb/blob/master/rcb-rsync.sh>`_

rcb-rsync-back.sh
-----------------

`[rcb-rsync-back.sh] <https://github.com/vbotka/rcb/blob/master/rcb-rsync-back.sh>`_

rcb-decrypt.sh
--------------

`[rcb-decrypt.sh] <https://github.com/vbotka/rcb/blob/master/rcb-decrypt.sh>`_

rcb-restore.sh
--------------

`[rcb-restore.sh] <https://github.com/vbotka/rcb/blob/master/rcb-restore.sh>`_
