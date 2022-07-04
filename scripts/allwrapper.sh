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
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.3 |REN|05/04/2022| Removed waitdivisor
# 1.2 |REN|04/11/2022| added code to drive the parameters that can
#                    | be passed to onewrapper
# 1.1 |REN|03/11/2022| Onewrapper added a -l so we can start at a
#                    | larger number of iterations than 1.  Testing
#                    | has shown that the MBytes/sec is stable across
#                    | all values from 1 to 15+.  This should
#                    | dramatically reduce testing time
# 1.0 |REN|02/28/2022| Initial Release
#_____________________________________________________________________
########################################################################
source func.errecho
UCTdatetime=$(date -u "+%Y%m%d_%H%M")
testname="$(hostname)_${UCTdatetime}"
suffix=${UCTdatetime}
maxiterations=50
iterincrement=10
miniterations=1
nullout="-n"
parallel=""

USAGE="${0##*/} [-[hnp]] [-c <#>] [-l <#>] [-d <suffix>]\r\n
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
\t-l\t<#>\tStart the number of iterations at this value instead of\r\n
\t\t\tone.\r\n
\t-n\t\ttoggle send the hash output to /dev/null, default is -n\r\n
\t-p\t\tFor b2sum, run the hash application in 4 way parallel,\r\n
\t\t\tdefault is NOT parallel\r\n
"

optionargs="hl:np"
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
  onewrapper -c 1 ${nullout} ${parallel} -l 5 5 5
  onewrapper -c 512 ${nullout} ${parallel} -l 5 5 5
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
