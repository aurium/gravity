#!/bin/bash -e

if [ x$DEBUG == x1 -o x$DEBUG == xon -o x$DEBUG == xtrue ]; then
  debug=true
else
  debug=false
fi

cd "$(dirname "$0")"
zip=/tmp/gravity.zip

function generateJS() {
  file_name="$1"
  parent_sed_script="$2"
  ws="$(echo -en '[ \t]')"
  nws="$(echo -en '[^ \t]')"
  macro_re="^.*//$ws*macro$ws+($nws+)$ws*:$ws*([^\r\n]+).*\$"
  inc_re="^$ws*//$ws*include$ws+($nws+).*\$"

  sed_script="$(
    echo "$parent_sed_script"
    egrep "$macro_re" "$file_name.metajs" |
    while read macro_def; do
      macro_name="$( echo "$macro_def" | sed -r "s#$macro_re#\1#" )"
      macro_expr="$( echo "$macro_def" | sed -r "s#$macro_re#\2#; s#@([1-9])#\\\1#g" )"
      if ( echo "$macro_def" | grep -q '@' ); then
        echo "s#$macro_name\(([^),]+),?([^),]+)?\)#$macro_expr#g;"
      else
        echo "s#$macro_name#$macro_expr#g;"
      fi
    done
  )"

  $debug && echo -e "Macro replacements:$sed_script" >&2

  echo "(function() { // Start $file_name"
  sed -r "$sed_script" "$file_name.metajs" |
  while read line; do
    inc_file="$( echo $line | egrep "$inc_re" | sed -r "s#$inc_re#\1#" )"
    test -n "$inc_file" && echo ">> Including $inc_file" >&2
    if test -n "$inc_file"; then
      generateJS "$inc_file" "$sed_script"
    else
      echo "$line"
    fi
  done
  echo "})(); // End $file_name"
}

generateJS gravity > gravity.js

$debug || sed -ri 's#^.*//\s*debug\s*$##' gravity.js

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

if ! (
    uglifyjs gravity.js --screw-ie8 --mangle --compress --output=gravity.min.js &&
    cssc style.css > style.min.css
  ); then

  echo ">>>> MINIFY ERROR! <<<<" >&2
  (
    which espeak &&
    espeak -v en -s 150 'minifyer error' &
  ) >/dev/null 2>&1

else

  test -e $zip && rm $zip
  zip $zip gravity.min.js index.html style.min.css

  size=$( ls -l $zip | sed -r "s/.* $USER ([0-9]+) .*/\1/" )
  sizeK=$( ls -lh $zip | sed -r 's/.* ([0-9,.]+K) .*/\1/' )
  test $size -lt $((13*1024)) \
    && valuation="The package is o.k, with $sizeK." \
    || valuation="The package bigger than the limit, with $sizeK."
  echo "=> $valuation ($size of $((13*1024)) bytes)"
  $debug && echo "-> debug mode may generate a bigger package then the normal."
  ( which espeak &&
    espeak -v en -s 150 "$valuation" &
  ) >/dev/null 2>&1

fi

$debug && mv gravity.js gravity.min.js # non ugly code for browser debug

### Daemon #####################################################################

w=$COLUMNS
test -z "$w" && w=$(tput cols)
hr='-'
while [ ${#hr} -lt $w ]; do
  hr="-$hr"
done
echo $hr

if inotifywait -r "$(dirname "$0")" -e CLOSE_WRITE; then
  sleep 0.3
  exec "$0"
fi
