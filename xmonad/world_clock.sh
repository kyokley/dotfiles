#!/bin/bash

AUS="AUS: `env TZ=Australia/Melbourne date +'%a %b %_d %H:%M'`"
UK="UK: `env TZ=UTC date +'%a %b %_d %H:%M'`"
timezones=("$AUS" "$UK")

timezone=${timezones[$(($RANDOM%${#timezones[*]}))]}
echo $timezone
