#!/bin/bash
# (
  export FILE1='revision2.lst'
  export FILE2='sonic.lst'
  export FILTER='awk -F";" "{print substr(\$1,1,35)gensub(\"[[:space:]]+\", \" \", \"g\",substr(\$1,36))}"'
  export FILTER="cut -c 1-36"
  export FILTER="grep -Ev '^00000000 ' | awk -F';' '{print substr(\$1,1,35)gensub(\"[[:space:]]+\", \" \", \"g\",substr(\$1,36))}'"

  # eval "grep -E '^\S{8} \S' $FILE1 | $FILTER"
  # diff -EwburqN
  eval "diff -ibuwIBEZ <(grep -E '^\S{8} \S' $FILE1 | $FILTER)  <(grep -E '^\S{8} \S' $FILE2 | $FILTER)" | grep -E "^[-+][0-9A-F]{8}"| cut -c 2-37 | sort | uniq -w36 -u > diff.lst
  # awk '{print substr($1,1,35)gensub("[[:space:]]+", " ", "g",substr($1,36))}' > diff.lst
# )

# eval "diff -ibwIBEZ <(grep -E '^\S{8} \S' $FILE1 | $FILTER)  <(grep -E '^\S{8} \S' $FILE2 | $FILTER)" | (
#     lnum=0;
#     while read lprint; do
#         while [ $lnum -lt $lprint ]; do read line <&3; ((lnum++)); done;
#         echo $line;
#     done
# ) 3<md5sums.sort.XXX
