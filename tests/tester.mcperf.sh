#!/bin/bash
source func.kbytes
source func.nice2num
source func.errecho
source func.insufficient

TESTNAME="Test of funcdtion mcperf from \n\thttps://github.com/sailnfool/sysperf"
declare -a hashes

hashes=("b2sum" "sha1sum" "sha256sum" "sha512sum")

testname=biggertest
maxiterations=50
iterincrement=10
########################################################################
# Process the command line options
########################################################################
USAGE="${0##*/} <testname> <maxiterations> <increment>\r\n
\t\twhere <testname> (default ${testname}) is the name of the CSV\r\n
\t\tfile where the results are tabulated\r\n
\t\tand <maxiterations> (default ${maxiterations})is the number\r\n
\t\tof times that the test is performed for each hashtype.  Note\r\n
\t\tis multiplied by 1024\r\n
\t\t<increment> (default ${iterincrement}) is the number of\r\n
\t\tof iterations to bump the test count by each time\t\n
"

optionargs="h"
NUMARGS=0 #No arguments are mandatory

while getopts ${optionargs} name
do
  case ${name} in
  h)
      echo -e ${USAGE}
      exit 0
      ;;
  \?)
    errecho "-e" "invalid option: ${OPTARG}"
    errecho "-e" ${USAGE}
    ;;
  esac
done
shift $((OPTIND-1))

if [[ "$#" -lt ${NUMARGS} ]]
then
  errecho "-e" ${USAGE} $@
  insufficient ${NUMARGS} $@
  exit -2
fi

if [[ "$#" -ge "1" ]]
then
  testname=$1
  shift
fi
if [[ "$#" -ge "1" ]]
then
  maxiterations=$1
  shift
fi
if [[ "$#" -ge "1" ]]
then
  iterincrement=$1
  shift
fi
outdir=/tmp
testoutput=${testname}.csv
rawout=${testname}.raw
scripter=script.sh
outfile=${outdir}/${testoutput}
max=${maxiterations}
count=1
rm -f ${outdir}/${scripter} ${outfile} ${outdir}/sorted.${testoutput}
while [[ ${count} -le ${max} ]]
do
  for myhash in "${!hashes[@]}"
  do
    echo "mcperf -n -s ${hashes[${myhash}]} ${count}Kib" | 
      tee -a ${outdir}/${scripter}
  done
  if [[ "${count}" -eq "1" ]]
  then
    count=$((count+(iterincrement-1)))
  else
    count=$((count+iterincrement))
  fi
done
exit 1
bash ${outdir}/${scripter} | tee ${tmpdir}/${rawout}
cat ${tmpdir}/${rawout}  sed "s/|/ /g" tee -a ${outfile}
sort -u < ${outfile} > ${outdir}/sorted.${testoutput}
