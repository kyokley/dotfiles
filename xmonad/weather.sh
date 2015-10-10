#!/bin/bash

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

temp=`weather -i KORD | grep Temperature | egrep -e '-?[0-9]+\.?[0-9]*\sF' -o`
val=`echo $temp | egrep -e '-?[0-9]+\.?[0-9]*' -o`

conditions=`weather -i KORD | grep -P '(?<=Sky conditions: ).*' -o`

if float_cond "$val < 45.0"; then
    temp="<fc=#ac9cdb>${val}F ${conditions}</fc>"
elif float_cond "$val < 80.0"; then
    temp="<fc=#0ca961>${val}F ${conditions}</fc>"
else
    temp="<fc=#ff0000>${val}F ${conditions}</fc>"
fi

echo $temp
