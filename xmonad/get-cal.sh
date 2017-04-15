#1/bin/bash

python -c "import random; print random.choice([x for x in '''$(gcalcli agenda --nocolor --nostarted "$(date)" "$(date | awk '$4 = "23:59:59"')")'''.split('\n') if x])" | sed -r 's/\s+/ /g' | sed 's/No Events Found.../No Events/'
