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

if ! ( which cssc && which uglifyjs )>/dev/null; then
  echo "
  You don't have some minifyer build dependence.
  $ sudo npm install -g css-condense uglify-js
  "
  exit 1
fi

if ! ( which zip && which inotifywait )>/dev/null; then
  echo "
  You don't have some build dependence tools.
  $ sudo aptitude install zip inotify-tools
  "
  exit 1
fi

uglifyjs gravity.js --screw-ie8 --mangle --compress --output=gravity.min.js
uglifyjs riffwave.js --screw-ie8 --mangle --compress --output=riffwave.min.js
cssc style.css > style.min.css

test -e $zip && rm $zip
zip $zip gravity.min.js riffwave.min.js index.html style.min.css

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

if inotifywait -r "$(dirname "$0")" -e CLOSE_WRITE; then #--event CLOSE_WRITE; then
  sleep 0.3
  exec "$0"
fi
