Installation
============


Installation with Ansible
-------------------------

Two roles are used to install the project:

* :l:`vbotka.rcb`
* :l:`vbotka.rsnapshot`


.. important::

   * :l:`rsync` must be installed both on *rcb-clients* and *rcb-
     server* (see *Inventory hosts* below).

   * The roles :l:`vbotka.rcb` and :l:`vbotka.rsnapshot` configure
     *rcb-clients* only

   * On *rcb-clients*, :l:`rsync` will be installed by
     :l:`vbotka.rsnapshot` as a requirement of :l:`rsnapshot`

   * On the *rcb-server*, it's up to you to install :l:`rsync`


1) Required collections
^^^^^^^^^^^^^^^^^^^^^^^

The roles :l:`vbotka.rcb` and :l:`vbotka.rsnapshot` require collection
:l:`community.general`. In addition to this, :l:`vbotka.rcb` requires
also :l:`community.crypto`. These collections should be included in
standard Ansible packages. If they are not or if you want to use the
latest versions install them

.. code-block:: bash

  shell> ansible-galaxy collections install community.crypto
  shell> ansible-galaxy collections install community.general


2) Install rsnapshot
^^^^^^^^^^^^^^^^^^^^

Use Ansible role :l:`vbotka.rsnapshot` to install and configure
*rsnapshot* on the clients.

.. code-block:: bash

  shell> ansible-galaxy install vbotka.rsnapshot


Create playbook
"""""""""""""""

.. code-block:: yaml

  shell> cat rsnapshot.yml
  - hosts: rcb_clients
    become: true
    become_user: root
    become_method: sudo
    roles:
      - vbotka.rsnapshot


Configure rsnapshot
"""""""""""""""""""

.. code-block:: yaml

  rsnapshot_test: true
  rsnapshot_no_create_root: '0'
  rsnapshot_backup_points:
    - {dir: /etc/, host: localhost/}
    - {dir: /usr/local/etc/, host: localhost/}
    - {dir: /var/backups/, host: localhost/}
  rsnapshot_backup_points_test:
    - {dir: /scratch/rcb-test/, host: localhost/}
  rsnapshot_exclude:
    - regex: '.git/'
    - regex: '.#*'


Run the playbook
""""""""""""""""

.. code-block:: bash

  shell> ansible-playbook rsnapshot.yml


3) Install rcb
^^^^^^^^^^^^^^

Use Ansible roles :l:`vbotka.rcb` and :l:`vbotka.ansible_lib`

.. code-block:: bash

  shell> ansible-galaxy install vbotka.rcb
  shell> ansible-galaxy install vbotka.ansible_lib


Download the example of an Ansible project
""""""""""""""""""""""""""""""""""""""""""

Download the examples of the Ansible `playbooks, inventory and configuration <https://github.com/vbotka/rcb/tree/master/ansible>`_

.. code-block:: bash

  shell> tree .
  ├── ansible.cfg
  ├── hosts
  ├── rcb-backup-server.yml
  ├── rcb-devel.yml
  ├── rcb_privatekey_passphrase.yml
  └── rcb.yml

The playbooks **rcb.yml** and **rcb-backup-server.yml** configure the
*rcb-clients* and *rcb-server* respectively (see *Inventory hosts*
below). The playbook **rcb-devel.yml** is used in the development. The
file **rcb_privatekey_passphrase.yml** keeps the passphrase. It's
plain-text for the purpose of testing. In production, you might want
to encrypt it by `Ansible vault
<https://docs.ansible.com/ansible/latest/vault_guide/index.html#protecting-sensitive-data-with-ansible-vault>`_
or any other password management.


4) Configure rcb
^^^^^^^^^^^^^^^^


Configuration ansible.cfg
"""""""""""""""""""""""""

In the configuration file **ansible.cfg** change **roles_path** to
where you installed the role :l:`vbotka.rcb`

.. literalinclude:: ../../ansible/playbooks/ansible.cfg
  :language: ini


Inventory hosts
"""""""""""""""

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


Playbook rcb.yml
""""""""""""""""

In the playbook **rcb.yml** which will configure the client(s) in the
inventory group **rcb_clients**, change at least following variables:

  * **rcb_bck_host**: The backup server.

  * **rcb_rcb_bck_root**: The directory on the client which will be
    synchronized to backup server *{{ rcb_bck_dst }}/{{
    ansible_hostname }}*

  * **rcb_rcb_rst_root**: The directory on the client where the backup
    from the server will be eventually restored.
    
  * **rcb_rcb_crt_root**: The directory for the client certificate,
    keys, and passphrase.

  * **rcb_cert_cn**: CN of the client certificate.


.. literalinclude:: ../../ansible/playbooks/rcb.yml
  :language: yaml


Playbook rcb-backup-server.yml
""""""""""""""""""""""""""""""

In the playbook **rcb-backup-server.yml** which will configure the
server(s) in the inventory group **rcb_server**, change at least the
variable:

  * **rcb_bck_shell**: The login shell of *rcb_bck_user*

.. literalinclude:: ../../ansible/playbooks/rcb-backup-server.yml
  :language: yaml


.. note::

   You can customize this playbook and depending on the OS install the
   required :l:`rsync`.
	     

File rcb_privatekey_passphrase.yml
""""""""""""""""""""""""""""""""""

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
**{{ rcb_privatekey_passphrase_file }}** (default={{ rcb_rcb_crt_root
}}/pem-pass-phrase).


.. seealso::

   * `Protecting sensitive data with Ansible vault <https://docs.ansible.com/ansible/latest/vault_guide/index.html#protecting-sensitive-data-with-ansible-vault>`_
    
.. important::

   * Enable `DEFAULT_GATHERING
     <https://docs.ansible.com/ansible/latest/reference_appendices/config.html#default-gathering>`_. The variables **ansible_os_family** and **ansible_distribution_\***
     are needed to customize variables.

   * The variable **ansible_hostname** is needed to configure **rcb_clients**.


Review the configuration
""""""""""""""""""""""""

Enable both **rcb_debug** and **rcb_debug_classified**

.. literalinclude:: code/debug_01.yml
  :language: yaml


5) Run Ansible playbooks
^^^^^^^^^^^^^^^^^^^^^^^^

Following workflow was tested with Ubuntu **rcb_clients** and FreeBSD **rcb_server**.


phase1. Create root's SSH keys on rcb-clients
"""""""""""""""""""""""""""""""""""""""""""""

Create root's SSH keys on the hosts from the inventory group
**rcb_clients** and store the public keys on the localhost in the
directory **{{ rcb_root_public_keys_dir }}/{{ rcb_bck_host }}/root-{{
ansible_hostname }}.id_rsa.pub**. root on the hosts from the inventory
group **rcb_clients** will be authorized to ssh to **{{ rcb_bck_user
}}@{{ rcb_bck_host }}**

.. code-block:: bash

  shell> ansible-playbook -t phase1 rcb.yml


Configure rcb-server
""""""""""""""""""""

Create user **{{ rcb_bck_user }}**. Create directories for encrypted
backups **{{ rcb_bck_dst }}** and to test the encrypted backups **{{
rcb_bck_dst_test }}**. Configure the ssh access of **rcb_clients** to
**rcb_server**. Put the root's public keys of **rcb_clients**, created
in phase1, into the **~/.ssh/authorized_keys** of **{{ rcb_bck_user
}}** on the host(s) from the inventory group **rcb_server**.

.. code-block:: bash

  shell> ansible-playbook rcb-backup-server.yml


phase2. Configure rcb-clients
"""""""""""""""""""""""""""""

.. code-block:: bash

  shell> ansible-playbook -t phase2 rcb.yml

