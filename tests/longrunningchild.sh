#!/bin/bash
filename=/tmp/$(hostname)_log_$$.txt
touch ${filename}
for i in {1..100}
do
  echo "$i" >> /tmp/$(hostname)_log_$$.txt
  sleep 10
done
exit 0
