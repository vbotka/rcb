cron
====

There are more options how to configure cron:

1) Use Ansible role :l:`vbotka.rcb`

Default value is *rcb_rsnapshot_cron=false*. This means crontab will
not be configured by default. Set *rcb_rsnapshot_cron=true* and
configure crontab. For example,

.. code-block:: yaml

  rcb_rsnapshot_cron: true
  rcb_rsnapshot_cron_user: root
  rcb_rsnapshot_cron_path: "{{ rcb_bin_dir }}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  rcb_rsnapshot_cron_mailto: root
  rcb_rsnapshot_cron_hourly_hour: '*/4'
  rcb_rsnapshot_cron_hourly_minute: '15'
  rcb_rsnapshot_cron_hourly_command: 'rcb-rsnapshot.sh -i=hourly'
  rcb_rsnapshot_cron_daily_hour: '5'
  rcb_rsnapshot_cron_daily_minute: '15'
  rcb_rsnapshot_cron_daily_command: 'rcb-daily-rsync.sh'
  rcb_rsnapshot_cron_weekly_hour: '1'
  rcb_rsnapshot_cron_weekly_minute: '15'
  rcb_rsnapshot_cron_weekly_day: '1'
  rcb_rsnapshot_cron_weekly_command: 'rcb-rsnapshot.sh -i=weekly'
  rcb_rsnapshot_cron_monthly_hour: '2'
  rcb_rsnapshot_cron_monthly_minute: '15'
  rcb_rsnapshot_cron_monthly_day: '1'
  rcb_rsnapshot_cron_monthly_command: 'rcb-rsnapshot.sh -i=monthly'


Configure cron

.. code-block:: bash

  shell> ansible-playbook -t rcb_cron rcb.yml


Creates the crontab

.. code-block:: bash

  shell> crontab -l
  PATH=/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  MAILTO=root
  #Ansible: hourly rcb_rsnapshot
  15 */4 * * * rcb-rsnapshot.sh -i=hourly
  #Ansible: daily rcb_rsnapshot
  15 5 * * * rcb-daily-rsync.sh
  #Ansible: weekly rcb_rsnapshot
  15 1 * * 1 rcb-rsnapshot.sh -i=weekly
  #Ansible: monthly rcb_rsnapshot
  15 2 1 * * rcb-rsnapshot.sh -i=monthly


.. seealso:: The defaults of the Ansible role vbotka.rcb `defaults/main.yml <https://github.com/vbotka/ansible-rcb/blob/master/defaults/main.yml>`_

  
2) Use Ansible role :l:`vbotka.linux_postinstall`

If the system is Linux the systemic way is to keep
*rcb_rsnapshot_cron=false* and configure all crontab entries of the
system with Ansible role :l:`vbotka.linux_postinstall`. To use this
role, install it

.. code-block:: Bash

  shell> ansible-galaxy install vbotka.linux_postinstall


and configure the variables *lp_cron_var* and *lp_cron_tab*

.. code-block:: yaml

  lp_cron_var:
    - {user: root, name: MAILTO, value: root}

  lp_cron_tab:
    - {state: present,
       user: root,
       name: hourly rcb_rsnapshot,
       minute: '15', hour: '*/4', day: '*', month: '*', weekday: '*',
       command: 'rcb-rsnapshot.sh -i=hourly'}
    - {state: present,
       user: root,
       name: daily rcb_rsnapshot,
       minute: '15', hour: '5', day: '*', month: '*', weekday: '*',
       command: 'rcb-daily-rsync.sh'}
    - {state: present,
       user: root,
       name: weekly rcb_rsnapshot,
       minute: '15', hour: '1', day: '*', month: '*', weekday: '1',
       command: 'rcb-rsnapshot.sh -i=weekly'}
    - {state: present,
       user: root,
       name: monthly rcb_rsnapshot,
       minute: '15', hour: '2', day: '1', month: '*', weekday: '*',
       command: 'rcb-rsnapshot.sh -i=monthly'}


The below playbook will create the same crontab

.. code-block:: Bash

  shell> ansible-playbook -t lp_cron linux-postinstall.yml


.. seealso:: The documentation at readthedocs.io `Ansible role Linux postinstall <https://ansible-linux-postinstall.readthedocs.io/en/latest/>`_


3) Manual configuration of cron

For manual configuration of cron RCB project provides `crontab example <https://github.com/vbotka/rcb/blob/master/crontab.example>`_ .
