#!/bin/bash
 
# Counts the number of multipath devices showing only one path
# Expected result = 0

cat /dev/null > /root/CheckDualMPath_output

expected=2

for disk in `cat /etc/multipath/bindings | grep -v '^[[:blank:]]*#' | grep -v -e '^[[:space:]]*$' | sort | awk '{print $1}'`
do PATHS=$(multipath -ll $disk | grep sd | wc -l)
output=$(($expected-$PATHS))
        if [ $output -gt 0 ]
        then 
                echo $output >> /root/CheckDualMPath_output
        fi
done

cat /root/CheckDualMPath_output | wc -l