Configure cron
==============



1. Use Ansible role `vbotka.rcb <https://galaxy.ansible.com/vbotka/rcb/>`_

Default value is *rcb_rsnapshot_cron=false*. This means crontab will not be configured by default. Set *rcb_rsnapshot_cron=true* to configure crontab

.. code-block:: yaml

  rcb_rsnapshot_cron: true


.. seealso:: The defaults of the Ansible role vbotka.rcb `defaults/main.yml <https://github.com/vbotka/ansible-rcb/blob/master/defaults/main.yml>`_

  
2. Use Ansible role `vbotka.linux_postinstall <https://galaxy.ansible.com/vbotka/linux-postinstall/>`_

If the system is Linux the systemic way is to keep *rcb_rsnapshot_cron=false* and configure all crontab entries of the system with Ansible role `vbotka.linux_postinstall <https://galaxy.ansible.com/vbotka/linux-postinstall/>`_. To use this role, install it

.. code-block:: Bash

  shell> ansible-galaxy install vbotka.linux_postinstall

and configure the variables *lp_cron_var* and *lp_cron_tab*. Then configure the *linux-postinstall.yml* playbook and run it.

.. code-block:: Bash

  shell> ansible-playbook playbooks/linux-postinstall.yml -t lp_cron


.. seealso:: The documentation at readthedocs.io `Ansible role Linux postinstall <https://ansible-linux-postinstall.readthedocs.io/en/latest/>`_


3. Manual configuration of cron

For manual configuration of cron RCB project provides `crontab example <https://github.com/vbotka/rcb/blob/master/crontab.example>`_ .
