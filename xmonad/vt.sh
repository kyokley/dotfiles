#!/bin/bash

data=$(docker run --rm -it -v ~/.ssh:/root/.ssh --env VT_URL="https://almagest.dyndns.org:7001/vittlify/" --env VT_USERNAME=yokley --env VT_DEFAULT_LIST=personal kyokley/vt list -qu | awk 'NF > 1' | sort -R | head -n 1 | COLOR_DISABLE=true python -m colorclass)

guid=$(echo $data | awk '{print $1}')
info=$(echo $data | awk '{for(i=2;i<NF;++i) printf("%s ", $i)}')

echo "<fc=yellow>$guid</fc> <fc=blue>$info</fc>"
