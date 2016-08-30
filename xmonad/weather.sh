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

data=$(curl -H "Accept:application/json" 'http://api.openweathermap.org/data/2.5/weather?id=4887398&units=imperial&appid=c4f4551816bd45b67708bea102d93522')
val=$(echo $data | python -m json.tool | grep temp -w | grep -Poe '-?[0-9]*(?=\.?[0-9]*)' | head -n 1)
conditions=$(echo $data | python -m json.tool | grep description -w | head -n 1 | grep -Po '"[^"]+"' | tail -n 1 | tr -d '"')

if float_cond "$val < 45.0"; then
    temp="<fc=#ac9cdb>${val}F ${conditions}</fc>"
elif float_cond "$val < 80.0"; then
    temp="<fc=#0ca961>${val}F ${conditions}</fc>"
else
    temp="<fc=#ff0000>${val}F ${conditions}</fc>"
fi

echo $temp
