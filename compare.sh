#!/bin/bash
if [ -z "$1" ]; then
  export FILE1='revision2.lst'
else
  export FILE1="$1"
fi
export FILE2='sonic.lst'
#export FILTER='awk -F";" "{print substr(\$1,1,35)gensub(\"[[:space:]]+\", \" \", \"g\",substr(\$1,36))}"'
#export FILTER="cut -c 1-36"
export FILTER="grep -Ev '^00000000 ' | awk -F';' '{print substr(\$1,1,35)gensub(\"[[:space:]]+\", \" \", \"g\",substr(\$1,36))}' | grep -E '^[0-9A-F]{8} [0-9A-F]' | uniq -w36 -u"

# Echo out all changed instructions to diff.lst
eval "diff -ibuwIBEZ <(grep -E '^\S{8} \S' $FILE1 | $FILTER)  <(grep -E '^\S{8} \S' $FILE2 | $FILTER)" | grep -E '^[ +-]' | sort | uniq -s1 -w36 -c | grep -E '^\s+[1]\s+[-]' | cut -c10- | sort > diff.lst
