Installation
============

Installation with Ansible
-------------------------

Examples of playbooks and variables are available at `RCB <https://github.com/vbotka/rcb/tree/master/ansible>`_ project.


1. Install the role

.. code-block:: bash

  > ansible-galaxy install vbotka.rcb

   
2. Edit and change at least these variables

* *rcb_BCK_HOST* and *rcb_BCK_DST* in *vars/rcb.yml*
* *rcb_BCK_DST* in *vars/rcb-backup-server.yml*
* *hosts* in *playbooks/rcb.yml*
* *hosts* in *playbooks/rcb-backup-server.yml*

  
3. Following workflow was tested with Ubuntu and FreeBSD (remote Backup-Server)

Create SSH keys at Backup-Clients and stores the public keys at the localhost

.. code-block:: bash

  > rcb.yml -t phase1
  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t phase1

Configures the Backup-Server

.. code-block:: bash

  > rcb-backup-server.yml
  > ansible-playbook ~/.ansible/playbooks/rcb-backup-server.yml

Configures the Backup-Clients

.. code-block:: bash

  > rcb.yml -t phase2
  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t phase2


Test installation
-----------------

Run tests and check /var/log/rcb.log for potential errors

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t testall

