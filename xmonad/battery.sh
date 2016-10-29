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


val=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | grep percentage | awk '{print $2}' | grep -Po '\d+')

refstr='charging'
refstr2='fully-charged'
batcond=$(upower --show-info /org/freedesktop/UPower/devices/battery_BAT0 | grep state | awk '{print $2}')

batcond=`python -c "print ('$refstr' == '$batcond' or '$refstr2' == '$batcond') and 'AC' or 'Batt'"`

if float_cond "$val < 35"; then
    temp="${batcond}: <fc=#ff0000>${val}%</fc>"
elif float_cond "$val < 75"; then
    temp="${batcond}: <fc=#ac9cdb>${val}%</fc>"
else
    temp="${batcond}: <fc=#0ca961>${val}%</fc>"
fi

echo $temp
