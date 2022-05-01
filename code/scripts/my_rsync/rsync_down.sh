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
    echo "SYNC DOWN from $remote_host" 
    cd "$root"
    rsync -azPhv --exclude-from "$down_exclude_path" --progress -e "ssh -p $port"  "$remote_user@$remote_host:$remote_path" "$local_path"
    echo ""
} 2>&1 | tee -a $DEBUG_LOG

