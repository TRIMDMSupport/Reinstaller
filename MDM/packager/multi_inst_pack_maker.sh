#!/bin/bash

loggedInUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Directory to parse
DIRECTORY="/Users/${loggedInUser}/Documents/Work/MT/Mac_development/Reinstaller/MDM/MT_Intune"

SCRIPT_TO_CALL="./packager.sh"
# Iterate over each file in the directory
for FILE in "$DIRECTORY"/*; do
  if [ -f "$FILE" ]; then
    FILENAME=$(basename "$FILE")

    fourth_block=$(echo "$FILENAME" | awk -F '[_|.]' '{print $4}')
    pkgname="$fourth_block"
    pkgid="com.github.payload_free.${fourth_block}"
    pkgvers="1.1"

    "$SCRIPT_TO_CALL" "$pkgname" "$pkgid" "$pkgvers" "$DIRECTORY"
  fi
done
