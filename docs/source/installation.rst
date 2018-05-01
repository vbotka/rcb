Installation
============

Installation with Ansible
-------------------------


1.Install Ansible role

.. code-block:: bash

  > ansible-galaxy install vbotka.rcb

   
2.Configure variables

Examples of playbooks and variables are available at `RCB <https://github.com/vbotka/rcb/tree/master/ansible>`_. Edit and change at least following variables.

* *rcb_BCK_HOST* and *rcb_BCK_DST* in *vars/rcb.yml*
* *rcb_BCK_DST* in *vars/rcb-backup-server.yml*
* *rcb_privatekey_passphrase* in *vars/rcb.yml*
* *rcb_cert_CN* in *vars/rcb.yml*
* *hosts* in *playbooks/rcb.yml*
* *hosts* in *playbooks/rcb-backup-server.yml*

  
3.Run Ansible playbooks

Following workflow was tested with Ubuntu(local Backup-Client) and FreeBSD (remote Backup-Server).

a) Create SSH keys at Backup-Clients and stores the public keys at the localhost

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t phase1

b) Configure the ssh access of Backup-Clients to Backup-Server. Store the public keys of Backup-Clients, created in phase1, into the ~/rcb_BCK_USER/.ssh/authorized_keys.

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb-backup-server.yml

c) Configure the Backup-Clients.

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t phase2


Test installation
-----------------

Run tests and check /var/log/rcb.log for potential errors

.. code-block:: bash

  > ansible-playbook ~/.ansible/playbooks/rcb.yml -t testall

