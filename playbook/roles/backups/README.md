# Backups role

Variables you can define:
```
backup_location: /var/backups

# If you don't define this, older than 4 days backups will be cleaned
backup_keep_max_days: 7

# If you don't define this variable. Database wont be backed up.
backup_db_name:
  - drupaldb1
  - drupaldb2

# If you do not define this variable. Files wont be backed up.
backup_files_path: /var/www/drupal/current/web/files
```
