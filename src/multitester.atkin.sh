#!/bin/bash
outfile="failoutput.txt"
sleeptime=5
cd ~/github/sysperf/src
if [[ -r ${outfile} ]]
then
  cat ${outfile}
fi
rm -f ${outfile}
sudo inxi -Fz > ${outfile}
for i in { 1 30 }
do
  echo -e "$i\tatkin copies - $(ps -ax | grep 'atkin ' | wc -l)" \
    "\t$(date)\r\n$(inxi -I --swap)"|tee -a  ${outfile}
  ./tester.atkin.sh 30 40 &
  sync
  sync
  sleep ${sleeptime}
done
