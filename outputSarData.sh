#!/bin/bash

# Outputs system activity data for a defined period

# Variables
HOSTNAME=`hostname -s`
START=null
END=null
LAST=null
FILE=null
VERBOSE=0
LASTDAY="null"

# Help text to display with option -h
Help()
{
  SARLIST=1
  echo "Syntax: outputSarData.sh [-h|u|s|e|f|l|v]
Options:
h    Print this help
u    Run as another user, file will be place in their home directory unless specified otherwise with '-f'
s    Start date for lookup (must be two digits) e.g. 01
e    End date for lookup (must be two digits) e.g. 01
f    Set output directory, default is /home/$USER/
l    Run sar on previous x number of days
v    Run in verbose mode

Example: outputSarData.sh -u testUser -f /tmp/sar -s 01 -e 05
This would run as testUser, output the file as /tmp/sar/sar_output_$HOSTNAME.txt and contain output from SAR between the 1st and 5th of the month"
}

# Setting what the options do
OPTSTRING=':hu:s:e:f:l:v'
while getopts ${OPTSTRING} opt
  do
    case $opt in
      h)  Help ;;
      u)  USER=${OPTARG} ;;
      s)  START=${OPTARG} ;;
      e)  END=${OPTARG} ;;
      f)  FILE=${OPTARG};;
      l)  LAST=${OPTARG} ;;
      v)  VERBOSE=1 ;;
      \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      :) echo "Option -$OPTARG requires an argument." >&2; exit 1 ;;
	esac
done

# Remove trailing forward slashes, if present
FILE="${FILE%/}"

# Set file output if none is set
if [ "$FILE" = "null" ]
  then
    FILE="/home/$USER/sar_output_$HOSTNAME.txt"
elif [[ "$FILE" == */ ]]
  then
    echo "Error: filepath ends in '/'"
    exit 1
else
  FILE=$FILE/sar_output_$HOSTNAME.txt
fi

# Run based on last dates (-l option)
if ! [ "$LAST" = "null" ]
  then
    SARLIST=`ls -t /var/log/sa/ | grep -v total | grep -v sar | head -$LAST | sed -r 's/^.{2}//'`
elif ! [ "$START" = "null" ] && ! [ $END = "null" ]
  then
    LASTDAY=`ls -t /var/log/sa/ | grep -v total | grep -v sar | grep -A 1 01 | grep -v 01 | sed -r 's/^.{2}//'`
fi

# Run based on date range (-s & -e options)
if ! [ $LASTDAY = "null" ]
  then
    if [ $START -gt $END ]
      then
        SARLIST1=`seq -w $START 01 $LASTDAY`
        SARLIST2=`seq -w 01 01 $END`
        SARLIST=`for n in $SARLIST1 $SARLIST2;
          do echo $n;
          done`
    else
      SARLIST=`seq -w $START 01 $END`
    fi
fi   
  
# Check list of SAR files is valid
if [ ${#SARLIST[@]} -eq 0 ]
  then
    echo "Error: No SAR files selected"
    exit 1
fi

# Actual command to run after all options have been input and checks done
RunSAR()
{
echo "Running SAR..."
for n in $SARLIST;
        do sar -f /var/log/sa/sa$n -A >> $FILE
      done
echo "SAR ran successfully. Output has been saved to $FILE"
}

# Running verbose options
if [ $VERBOSE -eq 1 ]
  then
    echo "User is set to $USER
  Output file will be saved to $FILE"
    if ! [ ${#SARLIST[@]} -eq 0 ]
      then
        echo "System activity (SAR) files to be saved are:"
    fi
    for n in $SARLIST;
      do echo sa$n
    done
    printf "Is this ok [y/N]:"
    read OK
    if ! [ "$OK" = "y" ]
      then
        echo "Operation aborted"
        exit 1
    else
      RunSAR
    fi
  else
    RunSAR
fi