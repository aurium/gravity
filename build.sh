#!/bin/bash -e

cd "$(dirname "$0")"
zip=/tmp/gravity.zip

ws="$(echo -en '[ \t]')"
nws="$(echo -en '[^ \t]')"
macro_re="^.*//$ws*macro$ws+($nws+)$ws*:$ws*([^\r\n]+).*\$"

sed_script=$(
  egrep "$macro_re" gravity.metajs |
  while read macro_def; do
    macro_name="$( echo "$macro_def" | sed -r "s#$macro_re#\1#" )"
    macro_expr="$( echo "$macro_def" | sed -r "s#$macro_re#\2#; s#@([1-9])#\\\1#g" )"
    if ( echo "$macro_def" | grep -q '@' ); then
      echo "s#$macro_name\(([^),]+),?([^),]+)?\)#$macro_expr#g;"
    else
      echo "s#$macro_name#$macro_expr#g;"
    fi
  done
  echo 's#//.*##;'
  echo 's#/\*[^*]+\*/##g;'
)

sed -r "$sed_script" gravity.metajs > gravity.js

test -e $zip && rm $zip
zip $zip gravity.js riffwave.js index.html style.css

size="$( ls -lh $zip | sed -r 's/.* ([0-9,.]+K) .*/\1/' )"
echo "=> $size"
(
  which espeak &&
  espeak -v mb-br1 -s 150 "o pacote deu $size" &
) >/dev/null 2>&1

### Daemon #####################################################################

w=$COLUMNS
test -z "$w" && w=$(tput cols)
hr='-'
while [ ${#hr} -lt $w ]; do
  hr="-$hr"
done
echo $hr

if inotifywait -r "$(dirname $0)" -e CLOSE_WRITE; then #--event CLOSE_WRITE; then
  sleep 0.3
  exec $0
fi
