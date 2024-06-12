#!/bin/bash

# Script to get the time of backup script completion and alert if it goes on too long
# Expected result = 1

# Check the log file was updated in the last 24 hours
is_new=`find /usr/local/admin/logs/ -mtime -1 -name 'LocalBackup.log' | wc -l`

# Check if the backup has failed or succeeded, if neither, it is hung
if [ $is_new == 1 ]; then
  backup_success=`grep -m 1 "Backup completed successfully" /usr/local/admin/logs/LocalBackup.log | wc -l`
  backup_fail=`grep -m 1 "failed with error" /usr/local/admin/logs/LocalBackup.log | wc -l`
  if [ $backup_success == 1 ] || [ $backup_fail == 1 ]; then
    echo "1"
  else
    echo "0"
  fi
fi