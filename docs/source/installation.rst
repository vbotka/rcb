Installation
============

Installation with Ansible
-------------------------


1) Install Ansible role `vbotka.rcb <https://galaxy.ansible.com/vbotka/rcb/>`_

.. code-block:: bash

  shell> ansible-galaxy install vbotka.rcb

   
2) Download the example of an Ansible project

Download the examples of the Ansible `playbooks, inventory and configuration <https://github.com/vbotka/rcb/tree/master/ansible>`_

.. code-block:: bash

  shell> tree .
  ├── ansible.cfg
  ├── hosts
  ├── rcb-backup-server.yml
  ├── rcb-devel.yml
  └── rcb.yml


3) Configure the project

* In the the configuration file *ansible.cfg* change *roles_path* to
  where you installed the role *vbotka.rcb*

.. code-block:: bash

  shell> cat ansible.cfg 
  [defaults]
  inventory = $PWD/hosts
  roles_path = $HOME/.ansible/roles
  stdout_callback = yaml


* There are two groups in the inventory *hosts*. To test the project,
  there is only one host in each group. Later you might want add more
  clients and, optionally, more servers. Fit the hosts and the
  variables to your needs

.. code-block:: bash

  shell> cat hosts
  [rcb_clients]
  10.1.0.12

  [rcb_clients:vars]
  ansible_connection=ssh
  ansible_user=admin
  ansible_python_interpreter=/usr/bin/python3.10

  [rcb_server]
  10.1.0.10

  [rcb_server:vars]
  ansible_connection=ssh
  ansible_user=admin
  ansible_python_interpreter=/usr/local/bin/python3.8

* In the playbook *rcb.yml* which will configure the clients
  *rcb_clients*, edit and change at least following variables:

  * rcb_bck_host; The backup server.
  * rcb_bck_dst; The directory at the backup server to store the backups.
  * rcb_root_public_keys_dir; The directory at the Ansible controller
    to store the public keys of the clients.
  * rcb_rcb_bck_root; The directory at the client which will be
    synchronized to *rcb_bck_dst*
  * rcb_rcb_rst_root; The directory at the client where the backup
    from the server will be eventually restored.

* In the playbook *rcb-backup-server.yml* which will configure the
  server, edit and change at least following variables:

  * rcb_bck_dst
  * rcb_root_public_keys_dir
  * rcb_bck_shell; The login shell of *rcb_bck_user*

* If you change *rcb_bck_user* and *rcb_bck_group* (defaults=rcbackup)
  do it in both playbooks

  * rcb_bck_user; The owner of the directory *rcb_bck_dst*
  * rcb_bck_group; The group of the directory *rcb_bck_dst*

.. note:: The variable *ansible_hostname* is needed to configure
          *rcb_clients*. Either enable `DEFAULT_GATHERING
          <https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-gathering>`_
          or set the variable manually.

  
4) Run Ansible playbooks

Following workflow was tested with Ubuntu (both localhost and
*rcb_clients*) and FreeBSD (remote *rcb_server*).

a) Create root's SSH keys on the hosts from the inventory group
   *rcb_clients* and store the public keys on the localhost in the
   directory `"{{ rcb_root_public_keys_dir }}/{{ rcb_bck_host
   }}/root-{{ ansible_hostname }}.id_rsa.pub"`. root on the hosts from
   the inventory group *rcb_clients* will be authorized to ssh to `"{{
   rcb_bck_user }}@{{ rcb_bck_host }}"`

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t phase1

b) Configure the ssh access of *rcb_clients* to *rcb_server*. Put the
   root's public keys of *rcb_clients*, created in phase1, into the
   *~/.ssh/authorized_keys* of *rcb_bck_user* on the host(s) from the
   inventory group *rcb_server*.

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

