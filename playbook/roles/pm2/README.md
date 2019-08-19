# pm2

Ansible role for pm2

This role was prepared and tested for Centos 7

# Usage

Add pm2 role to to your playbook
```
  roles:
   - { role: pm2, tags: [ 'pm2' ] }
```

# Default settings

```
pm2_user: www-admin
pm2_startup: systemd
pm2_home: /home/www-admin
```

# Using pm2 to run nodejs apps
Include ecosystem.config.js in your projects root directory with info
about paths to application(s) to run, ports and log formats. Example below:

```
module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps: [
    {
      name: 'MyApp1Stage',
      script: '/var/www/<myapp>/current/dist/index.js',
      env: {
      	// Do not put passwords or sensitive data here
        NODE_ENV: 'stage',
        RUN_PORT: '4006',
        ANY_ENV_VAR_YOU_NEED_TO_OVERRIDE_OR_HAVE_IN_ADDITION_TO_WHAT_IS_IN_SERVER_ENV: 'myvalue',
      },
      log_date_format: 'YYYY-MM-DD HH:mm Z',
      error_file: '/var/log/pm2/myapp1.stage.err.log',
      out_file: '/var/log/pm2/myapp1.stage.out.log',
    },
    {
      name: 'MyApp1Dev',
      script: '/var/www/<myapp>/current/dist/index.js',
      env: {
        // Do not put passwords or sensitive data here
        NODE_ENV: 'dev',
        RUN_PORT: '4004',
        ANY_ENV_VAR_YOU_NEED_TO_OVERRIDE_OR_HAVE_IN_ADDITION_TO_WHAT_IS_IN_SERVER_ENV: 'myvalue',
      },
      log_date_format: 'YYYY-MM-DD HH:mm Z',
      error_file: '/var/log/pm2/myapp1.dev.err.log',
      out_file: '/var/log/pm2/myapp1.dev.out.log',
    },
  ],
};
```
More details: http://pm2.keymetrics.io/docs/usage/application-declaration/


# Deploying
All commands have to be executed from user account that runs pm2 (default: www-admin)

```
pm2 delete MyApp1Dev
pm2 startOrRestart ecosystem.config.js --only MyApp1Dev
pm2 show MyApp1Dev
pm2 ls | grep MyApp1Dev | grep online
```

Save app state (server uses saved state app state info this to know what apps to start after service/server restart)
```
pm2 save
```

# Debugging
## Logs and status

Check logs at /var/log/pm2/
Also following commands migh be handy:

```
pm2 ls 
pm2 show MyApp1Dev
pm2 logs MyApp1Dev --lines 100
```

Also all systemd commands should work e.g.
```
systemctl status pm2-www-admin
systemctl restart pm2-www-admin
```
(however to pick up new config app may need to be deleted with `pm2 delete MyApp1Dev` 
first and then started with pm2 and passing ecosystem.config.js - see below)

## Start/restart
pm2 delete MyApp1Dev
pm2 startOrRestart /var/www/<myapp>/current/ecosystem.config.js --only MyApp1Dev
