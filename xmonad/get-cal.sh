#1/bin/bash

python -c "import random; print random.choice([x for x in '''$(gcalcli --prefix '%a %b %d' --nocolor agenda "$(date)" "$(date | awk '$4 = "23:59:59"')")'''.split('\n') if x])" | sed -r 's/\s+/ /g' | sed 's/No Events Found.../No Events/'
