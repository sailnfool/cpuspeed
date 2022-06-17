#!/bin/bash
cd ~/github/sysperf/tests
if [[ -r test.txt ]]
then
  cat test.txt
fi
rm -f test.txt
for i in $(seq 1 30)
do
  echo -e "$i\tcopies of atkins - $(ps -ax | grep atkin | wc -l)" \
    "\t$(date)\r\n$(swapon --show)"|tee -a  test.txt
  ./tester.atkin.sh 30 40 &
  sleep 10
done
