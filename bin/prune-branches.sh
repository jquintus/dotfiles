#!/bin/bash

###############################################################################
# Script Name: prune-branches.sh
# Description: This script cleans up local branches that no longer have a
#              corresponding remote branch.
# Author: Josh Quintus
# Source: https://stackoverflow.com/questions/7726949/remove-tracking-branches-no-longer-on-remote
# Usage: Run this script to fetch updates from the remote repository and 
#        remove local branches whose tracking branches have been deleted.
# Date: January 2025
###############################################################################

echo Fetch updates from remote and prune tracking branches that no longer exist on the remote
git fetch --prune

echo Deleting local branches whose remote tracking branches are gone
git branch -vv | awk '/: gone]/{print $1}' | xargs -r git branch -D

echo "Cleaned up local branches with no corresponding remote branches."

echo "Here's the remaining branches"
git branches
