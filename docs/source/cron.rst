Configure cron
==============


1. Configuration with current Ansible role

Default value is *rcb_rsnapshot_cron=no* e.g. crontab is not configured by default. It is posible to configure *rcb_rsnapshot_cron=yes* in *vars/rcb.yml* and use Ansible to configure crontab.

.. code-block:: yaml

  rcb_rsnapshot_cron: "yes"


Default values are in the block below.

.. code-block:: yaml

  rcb_rsnapshot_cron_user: "root"
  rcb_rsnapshot_cron_path: "{{ rcb_bin_dir }}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  rcb_rsnapshot_cron_mailto: "root"
  rcb_rsnapshot_cron_hourly_hour: "*/4"
  rcb_rsnapshot_cron_hourly_minute: "15"
  rcb_rsnapshot_cron_hourly_command: "rcb-rsnapshot.sh -i=hourly"
  rcb_rsnapshot_cron_daily_hour: "5"
  rcb_rsnapshot_cron_daily_minute: "15"
  rcb_rsnapshot_cron_daily_command: "rcb-daily-encrypt-rsync-decrypt-restore.sh"
  rcb_rsnapshot_cron_weekly_hour: "1"
  rcb_rsnapshot_cron_weekly_minute: "15"
  rcb_rsnapshot_cron_weekly_day: "1"
  rcb_rsnapshot_cron_weekly_command: "rcb-rsnapshot.sh -i=weekly"
  rcb_rsnapshot_cron_monthly_hour: "2"
  rcb_rsnapshot_cron_monthly_minute: "15"
  rcb_rsnapshot_cron_monthly_day: "1"
  rcb_rsnapshot_cron_monthly_command: "rcb-rsnapshot.sh -i=monthly"

  
2. Configuration with Ansible role `linux-postinstall <https://galaxy.ansible.com/vbotka/linux-postinstall/>`_

Systemic way is to keep *rcb_rsnapshot_cron=no* and configure all crontab entries of the system with Ansible role `linux-postinstall <https://galaxy.ansible.com/vbotka/linux-postinstall/>`_, if the system is Linux. To use this role, install it

.. code-block:: Bash

  > ansible-galaxy install vbotka.linux-postinstall

and configure the variables *lp_cron_var* and *lp_cron_tab*. Then configure the *linux-postinstall* playbook and run it.

.. code-block:: Bash

  > ansible-playbook playbooks/linux-postinstall.yml -t lp_cron


3. Manual configuration of cron

For manual configuration of cron RCB project provides `crontab example <https://github.com/vbotka/rcb/blob/master/crontab.example>`_ .
