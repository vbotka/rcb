Scripts
=======


`rcb-rsnapshot.sh <https://github.com/vbotka/rcb/blob/master/rcb-rsnapshot.sh>`_
--------------------------------------------------------------------------------

Run rsnapshot.

.. code-block:: bash

  > /root/bin/rcb-rsnapshot.sh
  rcb-rsnapshot.sh [-h|--help] [-i|--increment=[hourly,daily,weekly,monthly]] -- rsnapshot backup
  where:
      -h --help show this help text
      -i --increment is one of the options: hourly,daily,weekly or monthly


`rcb-encrypt.sh <https://github.com/vbotka/rcb/blob/master/rcb-encrypt.sh>`_
----------------------------------------------------------------------------

   1. Delete files in directory $RCB_META. If directory $RCB_META doesn't exist, create it.
   
   2. Create directory $RCB_META/$REMOTE if it doesn't exist. REMOTE are the directories defined in BACKUP POINTS (3rd parameter) of rsnapshot.conf

   3. Store lists of empty directories, links, special files and sockets in the directory $RCB_META/$REMOTE. Create digests in $RCB_META/$REMOTE/$RCB_DIGESTS.

   4. Encrypt $RCB_BCK_ROOT/$RCB_BCK_PREFIX to $RCB_ENC.


`rcb-rsync.sh <https://github.com/vbotka/rcb/blob/master/rcb-rsync.sh>`_
--------------------------------------------------------------------------

Rsync encrypted data from SRC to DST, defined as follows

.. code-block:: bash

  SRC="$RCB_ENC"
  DST="$BCK_USER@$BCK_HOST:$BCK_DST"


`rcb-rsync-back.sh <https://github.com/vbotka/rcb/blob/master/rcb-rsync-back.sh>`_
------------------------------------------------------------------------------------

Restore encrypted data from the remote backup (SRC) to local (DST). SRC and DST are defined as follows.

.. code-block:: bash

  SRC="$BCK_USER@$BCK_HOST:$BCK_DST"
  DST="$RCB_ENCR"

Running the script with -l will symlink $RCB_ENC to $RCB_ENCR.

.. code-block:: bash

  USAGE="$(basename "$0") [-h|--help] [-l|--link] [-d|--delete] -- rsync from backup
  where:
    -h --help     show this help text
    -l --link     links the origin directory instead of rsync
    -d --delete   delete the destination defore rsync"


`rcb-decrypt.sh <https://github.com/vbotka/rcb/blob/master/rcb-decrypt.sh>`_
------------------------------------------------------------------------------

Dencrypt data from SRC to DST, defined as follows

.. code-block:: bash

  SRC="$RCB_ENCR"
  DST="$RCB_DEC"

Running the script with -d will delete data in DST before decryption.

.. code-block:: bash

  USAGE="$(basename "$0") [-h|--help] [-d|--delete] -- decrypt backup
  where:
    -h --help show this help text
    -d --delete already decrypted data, if exists"


`rcb-restore.sh <https://github.com/vbotka/rcb/blob/master/rcb-restore.sh>`_
------------------------------------------------------------------------------

Restore data to $RCB_RST_ROOT .
