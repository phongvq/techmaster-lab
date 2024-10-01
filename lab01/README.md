# Usage

Notes:
- `tar` needs to be installed
- if $source_dir not exist, script will show error and quit
- if $backup_dir not exist, it will be created, script continue
- backup file will be in gzip format, with following naming convention: backup_YYMMDD_HHMMSS.tar.gz
  - for example: backup_20241001_231304.tar.gz


```bash
# change SOURCE_DIR to the data dir you want to do backup
# change BACKUP_DIR to the directory that you want to store backup
SOURCE_DIR=$(pwd)/data BACKUP_DIR=$(pwd)/backup bash backup.bash

```

