Development
===========

To facilitate the deployment and testing the `rcb project <https://github.com/vbotka/rcb>`_ provides the playbook `rcb-devel <https://github.com/vbotka/rcb/blob/master/ansible/playbooks/rcb-devel.yml>`_ to copy the current version of the scripts to the staging. By default the current version is locked (source_lock_set: "yes"). This means that the `rcb role <https://galaxy.ansible.com/vbotka/rcb/>`_ won't accidentally overwrite it.

The following sequence of commands copy, patch and install the scripts.

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb-devel.yml
  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t rcb_patch
  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t rcb_copy


Testing
=======

The scripts can be tested.

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t testall

