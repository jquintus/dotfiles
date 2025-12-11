#!/bin/bash
# -----------------------------------------------------------------------------
# Script: watch.sh
# Description: Monitors the /Users/tu/BackToTheFutureSync directory for new files 
#              and prints the content of each new file to the console.
# Author: Josh Quintus
# Date: January 2024
# Usage: Run this script in the terminal to start monitoring a directory.
#        May require sudo if permissions are restricted.
# Dependencies: 
#        brew install fswatch
# -----------------------------------------------------------------------------

# Default directory to monitor
DEFAULT_DIR="/Users/tu/BackToTheFutureSync"

# Use the provided argument as the directory to monitor, or fall back to default
MONITOR_DIR="${1:-$DEFAULT_DIR}"

echo "Watching $MONITOR_DIR"

# Command to monitor file creation and updates in the directory
fswatch --event Created --event Updated "$MONITOR_DIR" | while read NEWFILE; do
    echo
    echo "$NEWFILE"
    jq . "$NEWFILE"
    echo

done
