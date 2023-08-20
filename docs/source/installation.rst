Installation
============

Installation with Ansible
-------------------------


1) Install Ansible role

.. code-block:: bash

  shell> ansible-galaxy install vbotka.rcb

   
2) Configure variables

Examples of playbooks and variables are available at `RCB <https://github.com/vbotka/rcb/tree/master/ansible>`_. The Ansible playbooks expect the content is downloaded to the directory `~/.ansible`

.. code-block:: bash

  shell> pwd
  /home/admin/.ansible

  shell> tree .
  .
  ├── hosts
  ├── playbooks
  │   ├── rcb-backup-server.yml
  │   ├── rcb-devel.yml
  │   └── rcb.yml
  └── vars
      ├── rcb-backup-server.yml
          └── rcb.yml


Edit and change at least following variables

* vars/rcb-backup-server.yml
  
  * rcb_bck_dst

* vars/rcb.yml

  * rcb_bck_host
  * rcb_bck_dst
  * rcb_cert_cn
  * rcb_privatekey_passphrase
    
* playbooks/rcb-backup-server.yml

  * hosts

* playbooks/rcb.yml

  * hosts

  
3) Run Ansible playbooks

Following workflow was tested with Ubuntu(local Backup-Client) and FreeBSD (remote Backup-Server).

a) Create SSH keys at Backup-Clients and stores the public keys at the localhost

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t phase1

b) Configure the ssh access of Backup-Clients to Backup-Server. Store the public keys of Backup-Clients, created in phase1, into the ~/rcb_bck_user/.ssh/authorized_keys

.. code-block:: bash

  shell> ansible-playbook rcb-backup-server.yml

c) Configure the Backup-Clients.

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t phase2


Test installation
-----------------

Run tests and check /var/log/rcb.log for potential errors

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t testall

