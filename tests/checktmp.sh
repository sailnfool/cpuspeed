#!/bin/bash
dictpath=/usr/share/dict/
language=american-english
numcopies=512
dictsize=$(stat --printf="%s" ${dictpath}/${language})
echo "Dictionary size is ${dictsize} bytes"
totsize=$((dictsize*numcopies))
echo "total size of ${numcopies} is ${totsize} bytes"
availtmp=$(echo "$(df /tmp | awk '/\/tmp/ {print $4}') * 1024" | bc)
echo "available /tmp space is ${availtmp} bytes"
percent_ask=$(echo "( ${totsize} * 100 ) / ( ${availtmp} )" | bc)
echo "Asking for ${percent_ask}% of /tmp"
