#!/bin/bash

# Script to get OS Release versions of linux servers and output them to a file

# Variables
OS_RELEASE=`cat /etc/os-release | grep -i ^version= | sed 's/VERSION="//' | sed 's/^[[:space:]]*//' | cut -f1 -d" "`
DIR=/home/$USER/
FILE="OS_VERSION.txt"
FILEPATH=$DIR$FILE
HOSTNAME=`hostname -s`
KERNEL_VER=`uname -r`
FORCE=0
NEWFILE=0
APPEND=0
VERBOSE=0

# Functions
Help(){
  echo "Usage: removeOldKernels.sh [-h|-a|-d|-o|-n|-f|-v]
    -h    Print this help
    -a    Append new line to existing file, default file is $FILEPATH unless specified
    -d    Set output directory, default is $DIR
    -o    Set output filepath, default is $FILEPATH
    -n    Create a new file rather than append a new line
    -f    Force run (skip dialog)
    -v    Run in verbose mode

    As default, this script will do the following:
    - Output to $FILEPATH
    - If that file exists, it will append ask to overwrite the file or append a new line
    - If that file does not exist, it will create it with headers"
  exit 1
}

Append(){
  echo "$HOSTNAME,$OS_RELEASE,$KERNEL_VER" >> $FILEPATH
}

NewFile(){
  echo "ServerName,OS_Version,Kernel_Version
$HOSTNAME,$OS_RELEASE,$KERNEL_VER" > $FILEPATH
}

# Setting what the options do
OPTSTRING='hfd:o:anv'
while getopts ${OPTSTRING} opt
  do
    case $opt in
      h)  Help ;;
      d)  DIR=${OPTARG}; DIR="${DIR%/}"; FILEPATH="$DIR/$FILE";;
      o)  FILEPATH=${OPTARG}; FILE=`echo $FILEPATH | sed 's|.*/||'`;;
      f)  FORCE=1 ; echo "Using force, bypassing checks";;
      a)  APPEND=1 ;;
      n)  NEWFILE=1; NewFile ;;
      v)  VERBOSE=1 ;;
      \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
	esac
done

# Check if file already exists and ask to overwrite if it does
# No force
EXISTS=`find $DIR -name $FILE 2>/dev/null | wc -l`
if [ $FORCE -eq 0 ] 
  then
    if [ $NEWFILE -eq 0 ] && [ $APPEND -eq 0 ]
      then
        # EXISTS=`find $DIR -name $FILE 2>/dev/null | wc -l`
        if [ $EXISTS -gt 0 ] && ! [ "$OVERWRITE" == "y" ]
          then
            printf "File already exists. Do you want to overwrite? [y/N]"
            read OVERWRITE
            if [ "$OVERWRITE" == "y" ] || [ "$OVERWRITE" == "Y" ]
              then 
                echo "File $FILEPATH will be overwritten"
                NewFile
            else
              printf "Append new line to file? [y/N]"
              read APPEND
              if [ "$APPEND" == "y" ] || [ "$APPEND" == "Y" ]
                then
                  echo "New line will be appended"
                  Append
              else
                echo "Exiting... Nothing to be done."
                exit 1
              fi
            fi
        elif [ $EXISTS -eq 0 ]
          then
            NewFile
        fi
    elif [ $NEWFILE -eq 1 ] && [ $APPEND -eq 0 ]
      then
        if [ $EXISTS -gt 0 ]
          then
            printf "File already exists. Do you want to overwrite? [y/N]"
            read OVERWRITE
              if [ "$OVERWRITE" == "y" ] || [ "$OVERWRITE" == "Y" ]
              then 
                echo "File $FILEPATH will be overwritten"
                NewFile
              else 
                echo "Exiting... Nothing to be done."
                exit 1
              fi
        else
          echo "New file will be created at $FILEPATH"
          NewFile
        fi
    elif [ $NEWFILE -eq 0 ] && [ $APPEND -eq 1 ]
      then
        echo "New line will be appended to file at $FILEPATH. If none exists, one will be created and a new line added."
        # EXISTS=`find $DIR -name $FILE 2>/dev/null | wc -l`
        if [ $EXISTS -gt 0 ]
          then
            Append
        elif [ $EXISTS -eq 0 ]
          then
            NewFile
        fi
    elif [ $NEWFILE -eq 1 ] && [ $APPEND -eq 1 ]
      then
        echo "You can't have everything. Either create a new file or append to existing."
        printf "Which will it be: [N]ew File or [A]ppend? [N/A]"
        read OPTION
        if [ "$OPTION" == "N" ] || [ "$OPTION" == "n" ]
          then
            NewFile
        elif [ "$OPTION" == "A" ] || [ "$OPTION" == "a" ]
          then
            Append
        else
          echo "No option selected. Exiting."
          exit 1
        fi
    fi
# Force selected  
elif [ $FORCE -eq 1 ] 
  then
    if [ $NEWFILE -eq 0 ] && [ $APPEND -eq 0 ]
      then
        if [ $EXISTS -gt 0 ]
          then
            Append
        elif [ $EXISTS -eq 0 ]
          then
            NewFile
        fi
    elif [ $NEWFILE -eq 1 ] && [ $APPEND -eq 0 ]
      then 
        NewFile
    elif [ $NEWFILE -eq 0 ] && [ $APPEND -eq 1 ]
      then
        Append
    elif [ $NEWFILE -eq 1 ] && [ $APPEND -eq 1 ]
      then
        echo "Cannot create new file and append. Exiting..."
        exit 1
    fi
fi

# Verbose option selected
if [ $VERBOSE -eq 1 ]
  then
    echo "OS Release of this server ($HOSTNAME): $OS_RELEASE"
    if [ $NEWFILE -eq 1 ]
      then 
        echo "Mode selected: New File
Creating new file: $FILEPATH"
    elif [ "$OVERWRITE" == "y" ] || [ "$OVERWRITE" == "Y" ]
      then
        echo "Mode selected: Overwrite
Overwriting file: $FILEPATH"
    elif [ "$APPEND" == "y" ] || [ "$APPEND" == "Y" ]
      then
        echo "Mode selected: Append
Appending new line to: $FILEPATH  
Line: `tail -1 $FILEPATH`
Added to: $FILEPATH"
    fi
    echo "Done."
fi