#!/bin/bash
 
# Lists any multipath capable devices that don't have multipath enabled
# Expected result = 0

multipath -d -v1 | wc -l