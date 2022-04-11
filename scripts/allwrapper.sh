#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# awrapper run mrapper for the single and 512 copy cases
#
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.2 | REN |04/11/2022| added code to drive the parameters that can 
#                      | be passed to onewrapper
# 1.1 | REN |03/11/2022| Onewrapper added a -l so we can start at a 
#                      | larger number of iterations than 1.  Testing
#                      | has shown that the MBytes/sec is stable across
#                      | all values from 1 to 15+.  This should
#                      | dramatically reduce testing time
# 1.0 | REN |02/28/2022| Initial Release
#_____________________________________________________________________
########################################################################
source func.errecho
UCTdatetime=$(date -u "+%Y%m%d_%H%M")
testname="$(hostname)_${UCTdatetime}"
suffix=${UCTdatetime}
maxiterations=50
iterincrement=10
miniterations=1
waitdivisor=8
nullout="-n"
parallel=""

USAGE="${0##*/} [-[hnp]] [-c <#>] [-l <#>] [-w <#>] [-d <suffix>]\r\n
\t\t[-f testname] [<maxiterations> [<increment>]]\r\n
\r\n
\t\t<maxiterations> (default ${maxiterations})is the number\r\n
\t\tof times that the test is performed for each hashtype.  Note\r\n
\t\tis multiplied by 1024\r\n
\t\t<increment> (default ${iterincrement}) is the number of\r\n
\t\tof iterations to bump the test count by each time\r\n
\t\tThis wrapper hard codes a number of defaults that are used to\r\n
\t\tinvoke onewrapper.  E.G., Onewrapper is invoked 2 times, to run\r\n
\t\twith counts of 1 and 512\r\n
\t\tfor hash programs that support them\r\n
\t-h\t\tOutput this message\r\n
\t-l\t<#>\tStart the number of iterations at this value instead of one.
\t-n\t\ttoggle send the hash output to /dev/null, default is -n\r\n
\t-p\t\tFor b2sum, run the hash application in 4 way parallel,\r\n
\t\t\tdefault is NOT parallel\r\n
\t-w\t<#>\tthe divisor used to provide a \"wait\" time for the \r\n
\t\t\tcopies operation to complete.  When making (e.g. 512)\r\n
\t\t\tcopies tof dictionary that is ~1MB in size, it takes\r\n
\t\t\ttime for that operation to complete so that it does\r\n
\t\t\tnot delay the \"timing\" function.  Using the\r\n
\t\t\tgraphical gnome tools that display the\r\n
\t\t\twrite operations for the system, I have experimented\r\n
\t\t\twith this on a Raspberry PI 4 and it appears that it\r\n
\t\t\ttakes a divisor value of between 8 and 20.   Your\r\n
\t\t\tmileage may vary so perform your own testing.\r\n
"

optionargs="hl:npw:"
NUMARGS=0
while getopts ${optionargs} name
do
  case ${name} in
  h)
    echo -e ${USAGE}
    exit 0
    ;;
  l)
    if [[ "${OPTARG}" =~ ${re_integer} ]]
    then
      miniterations="${OPTARG}"
    else
      errecho -e "-l requires an integer argument"
      errecho -e ${USAGE}
      exit 1
    fi
    ;;
  n)
    if [[ "${nullout}" = "-n" ]]
    then
      nullout=""
    fi
    ;;
  p)
    parallel="-p"
    ;;
  w)
    if [[ "${OPTARG}" =~ $re_integer ]]
    then
      waitdivisor="${OPTARG}"
    else
      errecho -e "-w require an integer argument"
      errecho -e ${USAGE}
      exit 1
    fi
    ;;
  \?)
    errecho "-e" "invalid option: ${OPTARG}"
    errecho "-e" ${USAGE}
    exit 1
    ;;
  esac
done
shift $((OPTIND-1))


if [[ $(which onewrapper) ]]
then

  ######################################################################
  # Create a set of shell scripts where the count of the number of
  # copies of the dictionary (-c 1) is given and the scripts will test
  # from one to 15K copies in increments of 5K
  ######################################################################
  primename="script_$(hostname)_primes.sh"
  resultdir="~/github/sysperf/results"
  onewrapper -c 1 ${nullout} ${parallel} -w ${waitdivisor} -l 5 5 5
  onewrapper -c 512 ${nullout} ${parallel} -w ${waitdivisor} -l 5 5 5
else
  errecho -e "cannot find onewrapper.  Did you run make install?"
fi
set -x
if [[ -d ${resultdir} ]]
then
	echo "#!/bin/bash" > ${resultdir}/${primename}
	echo "primes 1 5kib" >> ${resultdir}/${primename}
	/bin/time ${resultdir}/${primename}
fi
