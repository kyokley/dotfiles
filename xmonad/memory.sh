#!/bin/bash

mem_stats=`free | grep Mem | grep -Po '^\D+\d+\s+\d+' | grep -Po '\d+\s+\d+$'`
total=`echo $mem_stats | grep -Po '^\d+'`
used=`echo $mem_stats | grep -Po '\d+$'`

#echo "$used / $total" | python -c "print round(float(raw_input()))"
echo "$used $total" | python -c "print str(100 * round(reduce(lambda x, y: float(x) / float(y), raw_input().split(' ')), 3)) + '%'"
