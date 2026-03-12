Development
===========

To facilitate the deployment and testing the `RCB (Rsync-Crypto-Backup)`_ project provides
the playbook `rcb-devel
<https://github.com/vbotka/rcb/blob/master/ansible/playbooks/rcb-devel.yml>`_ to copy the
current version of the scripts to the staging. By default, the current version is locked
*source_lock_set=true*. This means, that the role `vbotka.rcb`_ won't accidentally
overwrite it.

The following sequence of commands copy, patch and install the scripts

.. code-block:: bash

  shell> ansible-playbook rcb-devel.yml
  shell> ansible-playbook -t rcb_patch rcb.yml
  shell> ansible-playbook -t rcb_copy rcb.yml

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
