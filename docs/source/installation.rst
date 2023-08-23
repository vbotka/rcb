Installation
============

Installation with Ansible
-------------------------


Install Ansible role
^^^^^^^^^^^^^^^^^^^^

Install Ansible roles `vbotka.rcb <https://galaxy.ansible.com/vbotka/rcb/>`_ and `vbotka.ansible_lib <https://galaxy.ansible.com/vbotka/ansible_lib/>`_

.. code-block:: bash

  shell> ansible-galaxy install vbotka.rcb
  shell> ansible-galaxy install vbotka.ansible_lib


Install Ansible collections
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The role **vbotka.rcb** requires collections **community.general** and
**community.crypto**. These collections should be included in standard
Ansible packages. If the are not or if you want to use the latest
versions install them

.. code-block:: bash

  shell> ansible-galaxy collections install community.crypto
  shell> ansible-galaxy collections install community.general


Download the example of an Ansible project
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Download the examples of the Ansible `playbooks, inventory and configuration <https://github.com/vbotka/rcb/tree/master/ansible>`_

.. code-block:: bash

  shell> tree .
  ├── ansible.cfg
  ├── hosts
  ├── rcb-backup-server.yml
  ├── rcb-devel.yml
  ├── rcb_privatekey_passphrase.yml
  └── rcb.yml


Configure the project
^^^^^^^^^^^^^^^^^^^^^


ansible.cfg
"""""""""""

In the the configuration file **ansible.cfg** change **roles_path** to
where you installed the role **vbotka.rcb**

.. literalinclude:: ../../ansible/playbooks/ansible.cfg
  :language: ini


hosts
"""""

In the inventory **hosts**, there are two groups. To test the project,
there is only one host in each group. Later you might want add more
clients and, optionally, more servers. Fit the hosts and the variables
to your needs

.. literalinclude:: ../../ansible/playbooks/hosts
  :language: ini


Common variables in rcb.yml and rcb-backup-server.yml
"""""""""""""""""""""""""""""""""""""""""""""""""""""

Change the below variables in both playbooks:

  * **rcb_root_public_keys_dir**: The directory on the Ansible
    controller to store the public keys of the clients.

  * **rcb_bck_dst**: The directory on the backup server to store the
    backups.

  * **rcb_bck_user**: The owner of the directory *rcb_bck_dst*
    
  * **rcb_bck_group**: The group of the directory *rcb_bck_dst*


rcb.yml
"""""""

In the playbook **rcb.yml** which will configure the clients
**rcb_clients**, change at least following variables:

  * **rcb_bck_host**: The backup server.

  * **rcb_rcb_bck_root**: The directory on the client which will be
    synchronized to *{{ rcb_bck_dst }}/{{ ansible_hostname }}*

  * **rcb_rcb_rst_root**: The directory on the client where the backup
    from the server will be eventually restored.
    
  * **rcb_rcb_crt_root**: The directory for the client certificate,
    keys, and passphrase.

  * **rcb_cert_cn**: CN of the client certificate.


.. literalinclude:: ../../ansible/playbooks/rcb.yml
  :language: yaml


rcb-backup-server.yml
"""""""""""""""""""""

In the playbook **rcb-backup-server.yml** which will configure the
server(s) **rcb_server**, change at least following variable:

  * **rcb_bck_shell**: The login shell of *rcb_bck_user*

.. literalinclude:: ../../ansible/playbooks/rcb-backup-server.yml
  :language: yaml


rcb_privatekey_passphrase.yml
"""""""""""""""""""""""""""""

Create a file with passphrase to the private key of the client
certificate

.. literalinclude:: ../../ansible/playbooks/rcb_privatekey_passphrase.yml
  :language: yaml

Include the file **rcb_privatekey_passphrase.yml** in the playbook
**rcb.yml**. The passphrase will be used to generate OpenSSL:

  * Private key **{{ rcb_rcb_crt_root }}/backup.key**

  * Certificate Signing Request **{{ rcb_rcb_crt_root }}/backup.csr**

  * Self Signed Certificate **{{ rcb_rcb_crt_root }}/backup.crt**

For later use, the passphrase will be stored in the file
**{{ rcb_privatekey_passphrase_file }}** (default: {{ rcb_rcb_crt_root
}}/pem-pass-phrase).


.. seealso:: `Protecting sensitive data with Ansible vault <https://docs.ansible.com/ansible/latest/vault_guide/index.html#protecting-sensitive-data-with-ansible-vault>`_
    
.. note:: Enable `DEFAULT_GATHERING <https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-gathering>`_. The variable **ansible_hostname** is needed to configure **rcb_clients**. Also variables **ansible_os_family** and **ansible_distribution_\*** are needed to customize variables.


Review the configuration
^^^^^^^^^^^^^^^^^^^^^^^^

Enable both **rcb_debug** and **rcb_debug_classified** ::

  shell> ansible-playbook rcb.yml -t rcb_debug -e rcb_debug=true -e rcb_debug_classified=true

.. literalinclude:: code/debug_01.yml
  :language: yaml


Run Ansible playbooks
^^^^^^^^^^^^^^^^^^^^^

Following workflow was tested with Ubuntu **rcb_clients** and FreeBSD **rcb_server**.


phase1. Create root's SSH keys on the clients
"""""""""""""""""""""""""""""""""""""""""""""

Create root's SSH keys on the hosts from the inventory group
**rcb_clients** and store the public keys on the localhost in the
directory **{{ rcb_root_public_keys_dir }}/{{ rcb_bck_host }}/root-{{
ansible_hostname }}.id_rsa.pub**. root on the hosts from the inventory
group **rcb_clients** will be authorized to ssh to **{{ rcb_bck_user
}}@{{ rcb_bck_host }}**

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t phase1


Configure server
""""""""""""""""

Create user **{{ rcb_bck_user }}**. Create directory for encrypted backups
**{{ rcb_bck_dst }}**. Configure the ssh access of **rcb_clients** to
**rcb_server**. Put the root's public keys of **rcb_clients**, created in
phase1, into the **~/.ssh/authorized_keys** of **{{ rcb_bck_user }}** on the
host(s) from the inventory group **rcb_server**.

.. code-block:: bash

  shell> ansible-playbook rcb-backup-server.yml


phase2. Configure the clients
"""""""""""""""""""""""""""""

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t phase2


Test installation
-----------------

Run tests and check /var/log/rcb.log for potential errors

.. code-block:: bash

  shell> ansible-playbook rcb.yml -t testall
