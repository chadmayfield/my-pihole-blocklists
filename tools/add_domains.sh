#!/bin/bash

# add_domains.sh - add allow or disallowlisted domains from lists

# author  : Chad Mayfield (chad@chd.my)
# license : gplv3

list=${1,,}
allowlist="allow.list"
disallowlist="disallow.list"

command -v pihole >/dev/null 2>&1 || { \
    echo >&2 "ERROR: You must run this on a pi-hole!"; exit 1; }

load_list() {
    which_list="$1"

    if [ -f "$which_list" ]; then
        while read line
        do
            if ! [[ $line =~ ^# ]]; then
                if [[ $which_list =~ (allow) ]]; then
                    pihole -w "$line" | tee -a "logs/allowlist_add_$(date +%Y%m%d).log"
                elif [[ $which_list =~ (disallow) ]]; then
                    pihole -b "$line" | tee -a "logs/disallowlist_add_$(date +%Y%m%d).log"
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
    disallow)
        load_list "lists/disallow.list"
        ;;
    allow)
        load_list "lists/allow.list"
        ;;
    *)
        echo "ERROR: You must supply a list type! Either disallow or allow."
        echo "  e.g. $0 (disallow|allow)"
        ;;
esac

#EOF
