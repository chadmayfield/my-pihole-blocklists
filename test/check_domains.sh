#!/bin/bash

# check_domains.sh - PoC to check domains prior to committing to master

#arr=()
##while IFS= read -r line; do
##    arr+=( "$line" )
##done< <(curl -sI gitlab.blue.ros)
#
#mapfile -t arr < <(curl -sI google.com)
#
#for ((i = 0; i < ${#arr[@]}; i++))
#do
#    echo "${arr[$i]}"
#    sleep 1
#done
##printf '%s\n' "${arr[0]}"
##printf '%s\n' "${arr[1]}"
##printf '%s\n' "${arr[2]}"
##printf '%s\n' "${arr[3]}"

CHECKED=0

while read line
do
    check=$(curl -sI "$line" | grep -c "X-Pi-hole")
    echo "check = $check"

    if [ "$check" -ne 1 ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" "$line")
        echo "response = $response"

        if [[ $response =~ (200|301) ]]; then
            if [ $response -eq "200" ]; then
                echo "200 = $line"
                echo "$line" >> domains_not_being_blocked.txt
            elif [ $response -eq "301" ]; then
                location=$(curl -sI "$line"  | grep Location | awk -F ': ' '{print $2}' | sed 's|https\?:\/\/||')
                 # strip any trailing slashes
                 echo "301 = $location"
                 echo "$location" >> domains_not_being_blocked.txt
            else
                 echo "$line" >> domains_301_with_no_location.txt
        fi
    else
        echo "${response}|${line}" >> domains_unknown.txt
    fi
fi

let "CHECKED++"

echo "Domains checked: $CHECKED"

done < pi_blocklist_porn_top1m_www.list
