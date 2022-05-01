#!/bin/bash
# Credit to 
# - https://unix.stackexchange.com/questions/61931/redirect-all-subsequent-commands-stderr-using-exec
# - https://www.digitalocean.com/community/tutorials/an-introduction-to-linux-i-o-redirection
set -e
source scripts/my_rsync/config
DEBUG_LOG="scripts/my_rsync/log"
{
    echo ""
    echo "====== `date` ======="
    echo "SYNC UP to $remote_host" 
    rsync -azPhv --delete --exclude-from "$up_exclude_path" --progress -e "ssh -p $port" "$local_path" "$remote_user@$remote_host:$remote_path" 
    echo ""
} 2>&1 | tee -a $DEBUG_LOG

