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

mem_stats=$(free | grep 'Mem')
used=$(echo $mem_stats | awk '{print $3}')
total=$(echo $mem_stats | awk '{print $2}')

mem_val=$(echo "$used $total" | python -c "print str(int(100 * round(reduce(lambda x, y: float(x) / float(y), raw_input().split(' ')), 3)))")

if float_cond "$mem_val < 35"; then
    temp="Mem: <fc=#00ff00>${mem_val}</fc>%"
elif float_cond "$mem_val < 75"; then
    temp="Mem: <fc=#ac9cdb>${mem_val}</fc>%"
else
    temp="Mem: <fc=#ff0000>${mem_val}</fc>%"
fi

echo $temp
