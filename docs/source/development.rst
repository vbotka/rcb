Development
===========

To facilitate the deployment and testing the :l:`RCB (Rsync-Crypto-Backup)` project provides the playbook `rcb-devel <https://github.com/vbotka/rcb/blob/master/ansible/playbooks/rcb-devel.yml>`_ to copy the current version of the scripts to the staging. By default,
the current version is locked *source_lock_set=true*. This means, that
the role :l:`vbotka.rcb` won't accidentally overwrite it.

The following sequence of commands copy, patch and install the scripts

.. code-block:: bash

  shell> ansible-playbook rcb-devel.yml
  shell> ansible-playbook -t rcb_patch rcb.yml
  shell> ansible-playbook -t rcb_copy rcb.yml
