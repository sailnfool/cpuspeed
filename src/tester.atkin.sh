#!/bin/bash
source func.errecho
source func.regex

TESTNAME="Test of function atkin from \n\thttps://github.com/sailnfool/sysperf"

lopower=16
hipower=96
########################################################################
# Process the command line options
########################################################################
USAGE="${0##*/} [-h] [ <lo#> <hi#> ]\n
\t\texecute the memory consumptive atkins prime number sieve\n
\t\twhere <lo#> (default ${lopower} is the power of 2 at the low\n
\t\t\tend of testing\n
\t\tand <hi#> (default ${hipower}) is the high end power of 2 for\n
\t\t\ttesting\n
\t-h\t\tPrint this help information\n
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

if [[ $# -eq 2 ]]
then
  if [[ "$1" =~ $re_integer ]]
  then
    lopower="$1"
  else
    errecho "-e" "First parameter is not an integer"
    exit 1
  fi
  if [[ "$2" =~ $re_integer ]]
  then
    hipower="$2"
  else
    errecho "-e" "Second parameter is not an integer"
    exit 1
  fi
fi
ps="primeshell"
primeshell=/tmp/primeshell_$$.sh
primefile=/tmp/primefile_$$.txt

cat > ${primeshell}  <<EOF
#!/bin/bash
source func.regex
if [[ "\$#" -ne 1 ]]
then
  echo "\${0##/*} parameter #1 missing"
  exit -2
fi
if [[ ! "\$1" =~ \$re_integer ]]
then
  echo "\${0##/*} parameter is not an integer \$1"
  exit -1
fi
power2="\$1"
bignum=\$(echo "2^\${power2}-1"|bc)
echo -e "/tmp/primeshell.sh\t\${power2}\t\${bignum}"
atkin \${bignum}
exit \$?
EOF

chmod +x ${primeshell}
for pow2 in { ${lopower} ${hipower} }
do
  bignum=$(echo "2^${pow2}-1"|bc)
  echo -e "${0##/*}\t${pow2}\t${bignum}"
  ${primeshell} ${pow2} 2>&1 | tee -a ${primefile}
  exitstatus=$?
  if [[ "${exitstatus}" -ne 0 ]]
  then
    exit ${exitstatus}
  fi
done
