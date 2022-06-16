#!/bin/bash
source func.kbytes
source func.nice2num
source func.errecho
source func.insufficient

TESTNAME="Test of function atkin from \n\thttps://github.com/sailnfool/sysperf"

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

primeshell=/tmp/primeshell_$$.sh
cat > ${primeshell}  <<EOF
#!/bin/bash
bignum=$(echo "2^${1}-1"|bc)
echo -e "${0##/*}\t$1\t${bignum}"
atkin ${bignum}
exit $?
EOF
chmod +x ${primeshell}
for pow2 in $(seq 16 96)
do
  exitcode=$(${primeshell} ${pow2} 2>&1 | tee -a /tmp/primeshell_$$.txt)
  if [[ "${exitcode}" -ne 0 ]]
  then
    exit ${exitcode}
  fi
done

