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

drive="$1"

space_used=$(df -lh | tail -n +2 | grep -w "$drive" | awk '{print $5}' | head -c -2)
if float_cond "$space_used < 35"; then
    temp="$drive: <fc=#00ff00>${space_used}</fc>%"
elif float_cond "$space_used < 75"; then
    temp="$drive: <fc=#ac9cdb>${space_used}</fc>%"
else
    temp="$drive: <fc=#ff0000>${space_used}</fc>%"
fi

echo $temp
