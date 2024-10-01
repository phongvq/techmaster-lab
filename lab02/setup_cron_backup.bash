#!/usr/bin/env bash

# Variables
backup_script="${BACKUP_SCRIPT}"  # absoulute path to your backup script
backup_cron_log="${BACKUP_CRON_LOG_FILE:-${HOME}/backup.log}"
cron_job="0 2 * * * "${backup_script}" >> "${HOME}/backup.log" 2>&1"  # Cron job entry

# Check if the backup script exists
if [ ! -f "${backup_script}" ]; then
    echo "Error: Backup script not found at ${backup_script}"
    exit 1
fi

# Check if the cron job already exists
(crontab -l | grep -F "${backup_script}") &> /dev/null
if [ $? -eq 0 ]; then
    echo "Cron job already exists for ${backup_script}"
else
    # Add the new cron job to existing ones
    (crontab -l; echo "${cron_job}") | crontab -
    echo "Cron job added: ${cron_job}"
fi

