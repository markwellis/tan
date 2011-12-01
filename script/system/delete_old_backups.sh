#!/bin/bash

function debug(){
    if [ $DEBUG ]; then
        echo -e "\e[01;31m$@\e[00m"
    fi
}

if [ ! $1 ]; then
    debug "no dir provided, exiting"
    exit
fi

cd $1

dates=()
for i in $(ls | awk 'BEGIN{FS="[-|.]"} { print $1"-"$2 }' | uniq); do
    dates[${#dates[*]}]=$i
done

debug ${dates[@]}

#make sure we don't run if there's less than 2 months in dates

if [ ${#dates[@]} -lt 3 ]; then
    debug "no old backups, exiting"
    exit
fi

#delete last 2 items in $dates
unset dates[${#dates[@]}-1]
unset dates[${#dates[@]}-1]

for i in ${dates[*]};do
    debug "deleting ${i}*"
    rm ${i}*
done
