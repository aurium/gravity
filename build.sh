#!/bin/bash -e

cd "$(dirname "$0")"
zip=/tmp/gravity.zip

ws='[ \t]'
nws='[^ \t]'
macro_re="^.*//$ws*macro$ws+($nws+)$ws*:$ws*([^\r\n]+).*\$"

echo ==============================
sed_script=$(
  egrep "$macro_re" gravity.metajs |
  while read macro_def; do
    macro_name="$( echo "$macro_def" | sed -r "s#$macro_re#\1#" )"
    macro_expr="$( echo "$macro_def" | sed -r "s#$macro_re#\2#; s#@([1-9])#\\\1#g" )"
    echo "s#$macro_name\(([^),]+),?([^),]+)?\)#$macro_expr#g;"
  done
  echo 's#//.*##;'
  echo 's#/\*[^*]+\*/##g;'
)
echo "$sed_script"
echo ==============================

sed -r "$sed_script" gravity.metajs > gravity.js

test -e $zip && rm $zip
zip $zip gravity.js index.html

size="$( ls -lh $zip | sed -r 's/.* ([0-9,.]+K) .*/\1/' )"
echo "=> $size"
(
  which espeak &&
  espeak -v mb-br1 -s 150 "o pacote deu $size" &
) >/dev/null 2>&1
