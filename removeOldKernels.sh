#!/bin/bash

# Script to check version of RHEL/OEL and remove older versions of kernels

OS_RELEASE=`cat /etc/os-release | grep -i ^version= | sed 's/VERSION="//' | sed 's/^[[:space:]]*//' | cut -f1 -d" "`
OS_VERSION=`echo $OS_RELEASE | cut -f1 -d"." `
NUM=0
NUM_RM=0

Help(){
echo "Usage: removeOldKernels.sh [-h|-n|-v]
  -h    Print this help
  -n    Set number of old kernels to delete (1 or 2)
  -v    Run in verbose mode"
exit 1
}

Number(){
    printf "Enter number of previous kernels to delete [1/2]:"
    read NUM
    echo "Number of old kernels to delete: $NUM"
}

Verbose(){
    echo "OS Version is $OS_RELEASE"
# Number of old kernels to delete: $NUM
echo "Current kernel is "`uname -r`
echo "Currently installed kernels are:"
yum list installed | grep kernel
}

OPTSTRING=':n:hv'
while getopts ${OPTSTRING} opt
  do
    case $opt in
      h)  Help ;;
      n)  NUM=${OPTARG} ;;
      v)  Verbose ;;
      \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
	esac
done

if [ $NUM -eq 0 ]
  then
    Number
fi

if [ $NUM -eq 1 ]
  then
    NUM_RM=2
elif [ $NUM -eq 2 ]
  then
    NUM_RM=1
fi

if [ $NUM -eq 1 ] || [ $NUM -eq 2 ]
  then
    if [ $OS_VERSION -gt 7 ]
      then
        yum remove $(yum repoquery --installonly --latest-limit=-$NUM_RM -q) #-y
      else
        package-cleanup --oldkernels --count=$NUM
    fi
else
    echo "Invalid number of kernels entered. Please enter either 1 or 2."
    exit 1
fi