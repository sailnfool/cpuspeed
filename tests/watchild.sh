bash /tmp/t1.sh&
ischild=${!}
childid=$(ps -ef | grep $$ | awk '{print $2, $3, $8}' | grep $$ | \
  grep bash | cut -d " " -f 1 | grep -v $$|head -1)
if [[ -z "${childid}" ]]
then
  echo "child expired!"
else
  echo "ischild = ${ischild}, childid = ${childid}"
  sleep 3
  tail -f /tmp/$(hostname)_log_${childid}.txt
fi
