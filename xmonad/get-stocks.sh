#!/bin/bash

lf=/tmp/pidLockFile
# create empty lock file if none exists
cat /dev/null >> $lf
read lastPID < $lf
# if lastPID is not null and a process with that pid exists , exit
[ ! -z "$lastPID" -a -d /proc/$lastPID ] && echo "pass" && exit

# save my pid in the lock file
echo $$ > $lf

function float_cond()
{
    local cond=0
    if [[ $# -gt 0 ]]; then
        cond=$(echo "$*" | bc -q 2>/dev/null)
        if [[ -z "$cond" ]]; then cond=0; fi
        if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
    fi
    local stat=$((cond == 0))
    return $stat
}

cd ~/.xmonad

stockList=( `cat "stocks"` )
#counter=$((`date +%S`%${#stockList[*]}))
counter=$(($RANDOM%${#stockList[*]}))

arr=(`curl --connect-timeout 1 -m 4 -s http://download.finance.yahoo.com/d/quotes.csv?s=${stockList[$counter]}\&f=l1p2 | tr -d '\r"%' | tr "," "\n"`)
lastPrice=${arr[0]}

if float_cond "${arr[1]} < 0.0"; then
    lastPercent="<fc=#ff0000>${arr[1]}%</fc>"
else
    lastPercent="<fc=#00ff00>${arr[1]}%</fc>"
fi

echo ${stockList[$counter]}: $lastPrice $lastPercent
