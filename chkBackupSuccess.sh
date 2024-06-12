#!/bin/bash

# Check the backup log file to see if the latest backup was successful
# Expected result = 1

find /usr/local/admin/logs/ -newermt "`date +%D`" -name 'LocalBackup.log' -exec grep -m 1 -i 'Backup completed successfully' {} \; | wc -l