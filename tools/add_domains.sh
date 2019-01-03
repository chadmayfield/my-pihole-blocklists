#!/bin/bash

# add_domains.sh - add white or blacklisted domains from lists

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

list=${1,,}
whitelist="white.list"
blacklist="black.list"

command -v pihole >/dev/null 2>&1 || { \
    echo >&2 "ERROR: You must run this on a pi-hole!"; exit 1; }

load_list() {
    which_list="$1"

    if [ -f "$which_list" ]; then
        while read line
        do
            if ! [[ $line =~ ^# ]]; then
                if [[ $which_list =~ (white) ]]; then
                    pihole -w "$line" | tee -a "logs/whitelist_add_$(date +%Y%m%d).log"
                elif [[ $which_list =~ (black) ]]; then
                    pihole -b "$line" | tee -a "logs/blacklist_add_$(date +%Y%m%d).log"
                else
                    echo "ERROR: Unknown list type ${which_list}!"
                fi
            fi
        done < "$which_list"
    else
        echo "ERROR: List $which_list found!"
    fi
}

case $list in
    black)
        load_list "lists/black.list"
        ;;
    white)
        load_list "lists/white.list"
        ;;
    *)
        echo "ERROR: You must supply a list type! Either black or white."
        echo "  e.g. $0 (black|white)"
        ;;
esac

#EOF
