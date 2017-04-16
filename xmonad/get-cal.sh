#1/bin/bash

python -c "import random; print random.choice([x.strip() for x in '''$(gcalcli --xmobar --prefix '%a %b %d' agenda)'''.split('\n') if x.strip()])" | \
    sed -r 's/\s+/ /g' | \
    sed 's/No Events Found.../No Events/' | \
    sed -r 's/^\s*//'
