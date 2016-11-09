#!/bin/bash

echo $(echo $1 | tr '[:lower:]' '[:upper:]') $(curl --connect-timeout 1 -m 4 -s "http://download.finance.yahoo.com/d/quotes.csv?s=$1\&f=l1p2" | tr -d '"' | tr ',' ' ')
