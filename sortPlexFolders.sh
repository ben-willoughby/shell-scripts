#!/bin/bash

# This script organises the TV shows that Sonarr makes a mess of

# Variables
SHOWDIR=""
TVLIB="/var/lib/plexmediaserver/Library/TV"
ADDTOEXISTING=""
CORRECT=""
VIEW=""

# Functions
MoveFiles(){
  printf "Enter search string for TV Show (lower case):"
    read SEARCH
    FILES=()
      while IFS= read -r -d '' file; do
      FILES+=("$file")
      done < <(find "$TVLIB" \( -path "*$SHOWDIR*" -prune \) -o \( -type f -o -type d \) -a -iname "*$SEARCH*" -print0)
    echo "Files found:"
    for n in "${FILES[@]}"; do echo "$n"; done
    printf "Is this correct? [y/N]: "
    read CORRECTFILES
      if [ "$CORRECTFILES" == "N" ] || [ "$CORRECTFILES" == "n" ] || [ "$CORRECTFILES" == "" ]
        then
          echo "Nothing to be done. Exiting..."
          exit 1
      elif [ "$CORRECTFILES" == "Y" ] || [ "$CORRECTFILES" == "y" ]
        then
          echo "Moving files..."
          echo $FILES
          for n in "${FILES[@]}"; do mv "$n" $TVLIB/$SHOWDIR/; done
          echo "Done moving files."
          printf "Do you want to view folder listing? [y/N]:"
          read VIEW
          if [ "$VIEW" == "N" ] || [ "$VIEW" == "n" ] || [ "$VIEW" == "" ]
            then
              exit 1
          elif [ "$VIEW" == "Y" ] || [ "$VIEW" == "y" ]
            then
              ls $TVLIB/$SHOWDIR
          fi
      fi
}

# Ask for name of TV Show folder to be created
# Keep user stuck in a loop if folder name is empty
while [ "$SHOWDIR" == "" ]
  do
    printf "Enter name for TV Show folder:"
    read SHOWDIR
      if [ "$SHOWDIR" == "" ]
        then
          echo "Folder name cannot be blank."
      fi
done

# Checking if folder already exists
EXISTS=`find $TVLIB -name $SHOWDIR 2>/dev/null | wc -l`

if [ $EXISTS -gt 0 ]
  then
    printf "Folder already exists, do you want to run script for existing folder? [y/N]"
    read ADDTOEXISTING
      if [ "$ADDTOEXISTING" == "y" ] || [ "$ADDTOEXISTING" == "Y" ]
        then
          MoveFiles
          # exit 1
      elif [ "$ADDTOEXISTING" == "N" ] || [ "$ADDTOEXISTING" == "n" ] || [ "$ADDTOEXISTING" == "" ]
        then
          echo "Exiting... Nothing to be done."
          exit 1
      fi
elif [ $EXISTS -eq 0 ]
  then
    echo "Creating folder $SHOWDIR under $TVLIB"
    mkdir $TVLIB/$SHOWDIR
    MoveFiles
fi