#!/bin/bash

export VT_DEFAULT_LIST=personal
export VT_URL=https://almagest.dyndns.org:7001/vittlify/
data=$(~/virtualenvs/vittlify/bin/vt list -qu | COLOR_DISABLE=true ~/virtualenvs/vittlify/bin/python -m colorclass | awk 'NF > 1' | sort -R | head -n 1)

guid=$(echo $data | awk '{print $1}')
info=$(echo $data | awk '{$1=""; print $0}')

echo "<fc=yellow>$guid</fc> <fc=cyan>$info</fc>"
