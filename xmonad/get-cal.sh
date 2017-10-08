#!/bin/bash

python -c "import random; print random.choice([x.strip() for x in '''$(gcalcli --xmobar --prefix '%a %b %d' agenda "$(date -d 'now - 1 hour')" "$(date -d 'now + 120 hours')")'''.split('\n') if x.strip()])" | \
    sed -r 's/\s+/ /g' | \
    sed 's/No Events Found.../No Events/' | \
    sed -r 's/^\s*//'
