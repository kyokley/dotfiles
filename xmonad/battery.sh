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

full=`cat /proc/acpi/battery/BAT0/info | grep "last full capacity" | egrep -e '[0-9]+' -o`
current=`cat /proc/acpi/battery/BAT0/state | grep "remaining capacity" | egrep -e '[0-9]+' -o`

val=`python -c "blah=100 * ($current/${full}.0); print round(blah, 1)"`

refstr='charging'
refstr2='charged'
batcond=`cat /proc/acpi/battery/BAT0/state | grep "charging state" | egrep -e "(\<charging\>|\<charged\>)$" -o`

batcond=`python -c "print ('$refstr' == '$batcond' or '$refstr2' == '$batcond') and 'AC' or 'Batt'"`

if float_cond "$val < 35"; then
    temp="${batcond}: <fc=#ff0000>${val}%</fc>"
elif float_cond "$val < 75"; then
    temp="${batcond}: <fc=#ac9cdb>${val}%</fc>"
else
    temp="${batcond}: <fc=#0ca961>${val}%</fc>"
fi

echo $temp
