#!/usr/bin/env bash

# Định nghĩa các biến
source_dir="${SOURCE_DIR}"
backup_dir="${BACKUP_DIR}"
timestamp="$(date +"%Y%m%d_%H%M%S")"
backup_file="backup_${timestamp}.tar.gz"

# check if source dir exist
if [[ ! -d "$source_dir" ]]; then
    echo "source dir not exist: ${source_dir}"
    exit 1
fi

# check if backup dir exist, if not then create it
if [[ ! -d "${backup_dir}" ]]; then
    mkdir -p "${backup_dir}"
    echo "backup dir not exist -> created at: $backup_dir"
fi

# compress source and move to backup dir
# note that -C already change dir to $source_dir before doing compression, 
# so `.` refer to all files in $source_dir
tar -czvf "${backup_dir}/${backup_file}" -C "${source_dir}" .

# check compression status
if [[ $? -eq 0 ]]; then
    echo "Backup completed: ${backup_dir}/${backup_file}"
else
    echo "Error during backup."
    exit 1
fi

