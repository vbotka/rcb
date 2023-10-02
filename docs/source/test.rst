
Test
====

There are six tasks in the role :l:`vbotka.rcb` to test the
installation on the clients. Each task runs one of the scripts:

* *test1.yml* Create snapshot: *rcb-rsnapshot.sh -i=hourly*

* *test2.yml* Encrypt snapshots: *rcb-encrypt.sh*

* *test3.yml* Rsync encrypted snaphosts to the backup server: *rcb-rsync.sh*

* *test4.yml* Restore encrypted snapshots from the backup server: *rcb-rsync-back.sh*

* *test5.yml* Decrypt restored snapshots: *rcb-decrypt.sh --delete*

* *test6.yml* Restore data: *rcb-restore.sh*


Configure test in rsnapshot
---------------------------

If you enable *rsnapshot_test: true* the role :l:`vbotka.rsnapshot` in
Ubuntu creates the configuration file
*/usr/local/etc/rsnapshot-test.conf*. For the purpose of testing add
*backup* point(s) and *snapshot_root* to this configuration file. For
example,

.. code-block:: yaml

  rsnapshot_test: true
  rsnapshot_snapshot_root_test: /export/backup/snapshots-test
  rsnapshot_backup_points_test:
    - {dir: /scratch/rcb-test/, host: localhost/}


Display the variables

.. code-block:: yaml

  shell> ansible-playbook -t rsnapshot_test -e rsnapshot_debug=true -CD rsnapshot.yml

  ...

  TASK [vbotka.rsnapshot : test: DEBUG Print variables] ***************************************
  ok: [client] => 
    msg: |-
      Enable test ............ rsnapshot_test ................ True
      Rsnapshot config test .. rsnapshot_config_file_test .... /usr/local/etc/rsnapshot-test.conf
      Backup dir test ........ rsnapshot_snapshot_root_test .. /export/backup/snapshots-test
      Backup points test ..... rsnapshot_backup_points_test .. [{'dir': '/scratch/rcb-test/', 'host': 'localhost/'}]


.. note::

  In the role :l:`vbotka.rsnapshot`, the path to the configuration for
  testing is stored in the variable
  *rsnapshot_config_file_test*. Because this path may vary among the
  operating systems the defaults are stored in *vars/defaults*.


Create the directories for testing and the configuration file

.. code-block:: yaml

  shell> ansible-playbook -t rsnapshot_test rsnapshot.yml


Display the difference between *rsnapshot-test.conf* and *rsnapshot.conf*

.. code-block:: bash

  shell> diff rsnapshot-test.conf rsnapshot.conf
  6c6
  < snapshot_root /export/backup/snapshots-test
  ---
  > snapshot_root /export/backup/snapshots
  53c53,57
  < backup        /scratch/rcb-test/       localhost/
  ---
  > backup        /etc/                    localhost/
  > backup        /usr/local/etc/          localhost/
  > backup        /var/backups/            localhost/


Configure test in rcb
---------------------

By default the role :l:`vbotka.rcb` creates the configuration file
*/usr/local/etc/rcb-test.conf*. For the purpose of testing add the
destination of the test backup. For example,

.. code-block:: yaml

  rcb_bck_dst_test: /export/rcbackup-test


Display the variables

.. code-block:: yaml

  shell> ansible-playbook -t rcb_configure -e rcb_debug=true -CD rcb.yml

  ...

  TASK [vbotka.rcb : configure: DEBUG Print variables] *******************************************
  ok: [client] => 
    msg: |-
      Backup dir .......... rcb_rcb_bck_root .................. /export/backup
      Restore dir ......... rcb_rcb_rst_root .................. /export/restore
      Prefix .............. rcb_rcb_bck_prefix ................ snapshots/hourly.0
      Destination ......... rcb_bck_dst ....................... /export/rcbackup
      RCB config .......... rcb_etc_dir/rcb_conf .............. /usr/local/etc/rcb.conf
      Rsnapshot config .... rcb_etc_dir/rcb_rsnapshot_conf .... /usr/local/etc/rsnapshot.conf
      Prefix test ......... rcb_rcb_bck_prefix_test ........... snapshots-test/hourly.0
      Destination test .... rcb_bck_dst_test .................. /export/rcbackup-test
      RCB config test ..... rcb_etc_dir/rcb_conf_test ......... /usr/local/etc/rcb-test.conf
      Rsnapshot config test rcb_etc_dir/rcb_rsnapshot_conf_test /usr/local/etc/rsnapshot-test.conf


.. note::

  In the role :l:`vbotka.rcb`, the path to all configuration files is
  stored in the variable *rcb_etc_dir*. The default value
  */usr/local/etc* is stored in *defaults/main.yml*.


Create the directories and the configuration files

.. code-block:: yaml

  shell> ansible-playbook -t rcb_configure rcb.yml


Display the difference between *rcb-test.conf* and *rcb.conf*

.. code-block:: bash

  shell> diff rcb-test.conf rcb.conf
  5c5
  < BCK_DST="/export/rcbackup-test/client"
  ---
  > BCK_DST="/export/rcbackup/client"
  11c11
  < RCB_BCK_PREFIX="snapshots-test/hourly.0"
  ---
  > RCB_BCK_PREFIX="snapshots/hourly.0"
  47c47
  < RSNAPSHOT_PARAM="-c /usr/local/etc/rsnapshot-test.conf"
  ---
  > RSNAPSHOT_PARAM="-c /usr/local/etc/rsnapshot.conf"


Run the tests
-------------

By default the testing is disabled *rcb_test: false*.


test1
^^^^^

Enable testing and run the first test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test1 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 09:22:04 PM CEST [OK] *** hourly backup started
  Mon 02 Oct 2023 09:22:04 PM CEST [OK] *** hourly backup finished


.. note:: The default directory to test the backup is
   */scratch/rcb-test*. If you configured other directory in the
   variable *rsnapshot_backup_points_test*, used to create
   */usr/local/etc/rsnapshot-test.conf*, configure *rcb_test_dir*. See
   the file *tasks/test1.yml*.


test2
^^^^^

Run the second test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test2 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 09:36:33 PM CEST [OK] *** Encryption of backup started
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] files in /export/backup/meta deleted
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] /export/backup/meta/localhost created
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] mtree specification stored in /export/backup/meta/localhost/.rcb-mtree.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Empty dirs stored in /export/backup/meta/localhost/.rcb-empty-dirs.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Empty dirs stored in /export/backup/meta/localhost/.rcb-empty-dirs.tar
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Links stored in /export/backup/meta/localhost/.rcb-links.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Links stored in /export/backup/meta/localhost/.rcb-links.tar
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Fifo stored in /export/backup/meta/localhost/.rcb-specials.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Sockets stored in /export/backup/meta/localhost/.rcb-specials.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] Digests stored in /export/backup/meta/localhost/.rcb-digests.txt
  Mon 02 Oct 2023 09:36:33 PM CEST [OK] *** Encryption of /export/backup/snapshots-test/hourly.0 started
  Mon 02 Oct 2023 09:36:35 PM CEST [OK] *** Encryption of /export/backup/snapshots-test/hourly.0 finished


test3
^^^^^

Run the third test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test3 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 09:42:54 PM CEST [OK] *** Rsync from /export/backup/enc/ to rcbackup@10.1.0.10:/export/rcbackup-test/client started
  Mon 02 Oct 2023 09:42:54 PM CEST [OK] --include-from=/export/backup/meta/.rsyncrypto-export-changes
  Mon 02 Oct 2023 09:42:54 PM CEST [OK] RSYNC_RSH: ssh -o StrictHostKeyChecking=no
  Mon 02 Oct 2023 09:42:55 PM CEST [OK] *** Rsync from /export/backup/enc/ to rcbackup@10.1.0.10:/export/rcbackup-test/client finished


test4
^^^^^

Run the fourth test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test4 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 10:06:14 PM CEST [OK] *** Rsync from rcbackup@10.1.0.10:/export/rcbackup-test/client/ to /export/backup/enc.restored (link:false delete:false) started
  Mon 02 Oct 2023 10:06:14 PM CEST [OK] RSYNC_RSH: ssh -o StrictHostKeyChecking=no
  Mon 02 Oct 2023 10:06:14 PM CEST [OK] *** Rsync from rcbackup@10.1.0.10:/export/rcbackup-test/client/ to /export/backup/enc.restored finished


test5
^^^^^

Run the fifth test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test5 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 10:08:59 PM CEST [OK] *** Decryption from /export/backup/enc.restored to /export/backup/dec started
  Mon 02 Oct 2023 10:08:59 PM CEST [OK] Files in /export/backup/dec deleted
  Mon 02 Oct 2023 10:08:59 PM CEST [OK] *** Decryption from /export/backup/enc.restored to /export/backup/dec finished


test6
^^^^^

Run the sixth test

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t test6 rcb.yml


Take a look at */var/log/rcb.log*::

  Mon 02 Oct 2023 10:09:41 PM CEST [OK] *** Restoring data from /export/backup/dec started
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] localhost restored in /export/restore/localhost
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] Empty dirs created in /export/restore/localhost
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] Links created in /export/restore/localhost
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] mtree restored from /export/backup/meta/localhost/.rcb-mtree.txt to /export/restore/localhost
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] diff /export/backup/snapshots-test/hourly.0/localhost/ and /export/restore/localhost/ finished
  Mon 02 Oct 2023 10:09:41 PM CEST [OK] *** /export/backup/snapshots-test/hourly.0 restored in /export/restore


testall
^^^^^^^

You can run all test in one play

.. code-block:: bash

  shell> ansible-playbook -e rcb_test=true -t testall rcb.yml
