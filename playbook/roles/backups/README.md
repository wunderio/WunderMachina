# Backups role

Variables you can define:
```
backup_location: /var/backups

# If you don't define this, backups older than 4 days will be removed.
backup_keep_max_days: 7

# If you don't define this, the database won't be backed up.
backup_db_name:
  - drupaldb1
  - drupaldb2

# If you don't define this, files won't be backed up.
backup_files_path: /var/www/drupal/current/web/files
```
