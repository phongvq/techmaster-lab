# Usage

```bash

# replace $BACKUP_SCRIPT with the absolute path of your backup script
# replace $BACKUP_CRON_LOG_FILE with the absolute path of log file for the cronjob
BACKUP_SCRIPT=$BACKUP_SCRIPT BACKUP_CRON_LOG_FILE=$BACKUP_CRON_LOG_FILE bash setup_cron_backup.bash 

```

Notes:

- if $BACKUP_SCRIPT point to a non-exist file, script will be error, no cron will be setup
- if this cron has been set up before, script will be aborted
- $BACKUP_CRON_LOG_FILE is optional
  - if not set (default value), log of backup cron job will be output to `$HOME/backup.log`.
  - where $HOME is home dir of user _who run `setup_cron_backup.bash` script_.

# Example

```txt
# here, user `ubuntu` is running the setup script
$ BACKUP_SCRIPT=/tmp/a.bash bash setup_cron_backup.bash 
Cron job added: 0 2 * * * /tmp/a.bash >> /home/ubuntu/backup.log 2>&1

# re-run will show error because cronjob already exists
$ BACKUP_SCRIPT=/tmp/a.bash bash setup_cron_backup.bash 
Cron job already exists for /tmp/a.bash

# verify your result
$ crontab -l | grep a.bash
0 2 * * * /tmp/a.bash >> /home/ubuntu/backup.log 2>&1
```
