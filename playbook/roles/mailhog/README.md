# Ansible Role: Mailhog

## Variables

```
# mailhog configuration.
mailhog_binary_url: https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_amd64
mailhog_install_dir: /opt/mailhog

# ssmtp configuration.
ssmtp_mailhub: localhost:1025
ssmtp_root: postmaster
ssmtp_authuser: ""
ssmtp_authpass: ""
ssmtp_from_line_override: "YES"

# optional varibles, do not define if you don't need to use
mailhog_http_authuser: abra
mailhog_http_authpass: cadabra
```

Note: Remember to configure your PHP to use following sendmail path: ``/usr/sbin/ssmtp -t``
