#!/bin/bash
 
# Counts the number of multipath devices showing as anything other than "active"
# Expected result = 0

mpathTotal=`multipath -ll -v1 | wc -l`

mpathActive=`multipath -ll | grep "status=active" | wc -l`

diff=$(($mpathTotal-$mpathActive))
echo $diff