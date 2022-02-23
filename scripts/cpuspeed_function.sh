#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# cpuspeed - Collect relative performance data on CPU speed
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.1 | REN |02/20/2022| Track memory and swap usage as well as the
#                      | Date and time run
# 1.0 | REN |02/01/2022| Initial Release
#_____________________________________________________________________
#
########################################################################
# This script was motivated by the fact that I could run Ubuntu on a
# Raspberry PI 4 8GB (or 4GB) model.  The Linux Foundation edx script
# which # attempts to decide if a machine has the capacity to run their 
# courseware uses bogomips to determine the relative CPU speed of the
# subject system uses bogomips.  You can look at Wikipedia for more
# information on bogomips. The Linux Foundation script is
# "ready-for.sh" and it contains an internal database of the estimated
# performance levels necessary to run their courseware for various
# courseware.  I was taking a rather elementary course which was
# looking for a bogomips rating of 2000 as the minimum CPU performance
# for the courseware.  Running on a Raspberry PI4 8GB model the
# bogomips score came up with a value of 108, which would suggest that
# the Raspberry PI was too slow to run the courseware by a factor of 
# 20.  Since I was using these Raspberry PI machines for regular 
# desktop software development, I felt that this characterization was
# unrealistic for the Raspberry PI 4.  I have developed this script to
# develop some alternative measures of the system performance and to
# correlate this speed against existing bogomips scores to try to
# generate a "more fair" estimate of system peformance, especially for
# ARM CPUs (and emerging RISC V CPUS which I suspect will have the
# same measurement challenge).
#
# Using cryptograhic hashes against a dictionary as a proxy for
# bogospeed.  To give a variety of data, the driving script will invoke
# this with different iteration counts that will push memory, core and
# sample I/O rates.
#
# Note that this script also supports other cryptographic hash functions
# commonly found on Linux systems, including:
# sha1sum, sha256sum, sha512sum, b2sum
#
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.1 | REN |02/20/2022| Tweaked into a separate github repository
#                      | Added tracking of memory and swap as well as
#                      | a complete timestamp for each record created
#                      | Note that the timestamp is in UCT
# 1.0 | REN |02/01/2022| Initial Release
#
source func.nice2num
source func.errecho
source func.insufficient
source func.toseconds
source func.os

USAGE="\r\n${scriptname} [-h] [-l <language> ] <nicenumber>\r\n
\t\tProvide a nicenumber to control the iterations of the number of\r\n
\t\ttimes that we take the sha256sum of the local dictionary.  This\t\n
\t\twill report the architecture of the machine, the size of the\r\n
\t\tdictionary, the number of iterations, bogomips, time per hashing\r\n
\t\t10Mib characters as normalization\r\n
\t-h\tPrint this message\r\n
\t-l\t<language>\tthe name of an alternate dictionary\r\n
\t-n\tSend the hash output to /dev/null\r\n
\t-s\t<hashprogram>\tSpecify which cryptographic hash\r\n
\t\t\tprogram to use valid values:\r\n
\t\t\tb2sum; sha1sum; sha256sum; sha512sum\r\n
\t<nicenumber>\tA number in the format "1M" or "1Mib" to\r\n
\t\t\trepresent 1 M (Mbyte) ${__kbytesvalue["M"]}\r\n
\t\t\tor 1 Mib (Mbibyte) ${__kbibytesvalue["MIB"]}\r\n
\t\t\tor 1 Pib (Pbibyte) ${__kbibytesvalue["PIB"]}\r\n
\t\t\tor other bibyte prefix (e.g., eta or zeta)\r\n
\r\n
\t\tFor a complete table of nice suffixes and values\r\n
\t\t${scriptname} -v -h\r\n
"

########################################################################
# Define all of the optionargs documented in USAGE and set the 
# default values that can be overridden on the command lines.
########################################################################
optionargs="hl:ns:v"
NUMARGS=1
FUNC_DEBUG="0"
verbosemode="FALSE"
export FUNC_DEBUG
dictpath=/usr/share/dict/
language=american-english
OUTFILE=/tmp/timer_out$$.txt
hashprogram=$(which sha256sum)
timerfailure="FALSE"

########################################################################
# Process the Command Line options based on the Usage above
########################################################################
while getopts ${optionargs} name
do
  case ${name} in
  h)
    echo -e ${USAGE}
    if [[ "${verbosemode}" == "TRUE" ]]
    then
      for i in $(seq 0 $((${#__kbytessuffix}-1)) )
      do
        bytesuffix=${__kbytessuffix:${i}:1}
        echo -e "${bytesuffix}\t${__kbytesvalue[${bytesuffix}]}"
      done
      echo ""
      for i in $(seq 0 $((${#__kbytessuffix}-1)) )
      do
        bibytesuffix=${__kbibytessuffix[${i}]}
        echo -e "${bibytesuffix}\t${__kbibytesvalue[${bibytesuffix}]}"
      done
    fi
    exit 0
    ;;
  l)
    language="${OPTARG}"
    ;;
  s)
    hashprogram="${OPTARG}"
    case ${hashprogram} in
      b2sum)
        hashprogram=$(which ${hashprogram})
        hashprogram=${hashprogram##*/}
        ;;
      sha1sum)
        hashprogram=$(which ${hashprogram})
        hashprogram=${hashprogram##*/}
        ;;
      sha256sum)
        hashprogram=$(which ${hashprogram})
        hashprogram=${hashprogram##*/}
        ;;
      sha512sum)
        hashprogram=$(which ${hashprogram})
        hashprogram=${hashprogram##*/}
        ;;
      \?)
        errecho "-e" "Invalid hash program: ${OPTARG}"
        errecho "-e" ${USAGE}
        exit 2
    esac
    ;;
  n)
    OUTFILE="/dev/null"
    ;;
  v)
    verbosemode="TRUE"
    ;;
  \?)
    errecho "-e" "invalid option: ${OPTARG}"
    errecho "-e" ${USAGE}
    exit 1
    ;;
  esac
done
shift $((OPTIND-1))
########################################################################
# End of processing Command Line arguments
########################################################################


if [[ $# -lt ${NUMARGS} ]]
then
  errecho "-e" ${USAGE} $@
  insufficient ${NUMARGS} $@
  exit -2
else
  POWER=$1
fi

########################################################################
# Convert the nice notation to a number
########################################################################
iterations=$(nice2num "${POWER}")

########################################################################
# Create a shell script in /tmp which we will execute
########################################################################
TIMER_APP=/tmp/timer$$.sh
TIMER_OUT=/tmp/timeout$$.txt
rm -f /tmp/time*
cat > ${TIMER_APP} <<EOF
#!/bin/bash
if [[ "${OUTFILE}" != "/dev/null" ]]
then
  rm -f ${OUTFILE}
fi
i=0
while [[ \${i} -lt ${iterations} ]]
do
  ${hashprogram} ${dictpath}/${language} >> ${OUTFILE}
  i=\$((i+1))
done
if [[ "${OUTFILE}" != "/dev/null" ]]
then
  rm -f ${OUTFILE}
fi

EOF
chmod +x ${TIMER_APP}
/usr/bin/time ${TIMER_APP} 2> ${TIMER_OUT}
if [[ $? -ne 0 ]]
then
  timerfailure="TRUE"
fi
usertime=$(cat ${TIMER_OUT} | \
  sed -e '2d' -e '1,1s/^\([0-9:\.][0-9:\.]*\)user.*$/\1/')
userseconds=$(toseconds ${usertime})
systemtime=$(cat ${TIMER_OUT} | \
  sed -e '2d' -e '1,1s/^.*user \([0-9:\.][0-9:\.]*\)system.*$/\1/') 
systemseconds=$(toseconds ${systemtime})
elapsedtime=$(cat ${TIMER_OUT} | \
  sed -e '2d' -e '1,1s/^.*system \([0-9:\.][0-9:\.]*\)elapsed.*$/\1/')
elapsedseconds=$(toseconds ${elapsedtime})
if [[ "${timerfailure}" == "FALSE" ]]
then
  rm -f ${TIMER_APP} ${TIMER_OUT}
else
  bash -x ${TIMER_APP}
fi
Arch=$(uname -m)
maxCPU=$(lscpu | grep  -i "CPU max MHz" | \
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")
cores=$(lscpu | grep -i "^CPU(s)" |
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")
#!/bin/bash
memtotal=$(free -h | awk '/^Mem:/ {print $2}')
memused=$(free -h | awk '/^Mem:/ {print $3}')
memfree=$(free -h | awk '/^Mem:/ {print $4}')
swaptotal=$(free -h | awk '/^Swap:/ {print $2}')
swapused=$(free -h | awk '/^Swap:/ {print $3}')
swapfree=$(free -h | awk '/^Swap:/ {print $4}')
# echo "memtotal=${memtotal}"
# echo "memused=${memused}"
# echo "memfree=${memfree}"
# echo "swaptotal=${swaptotal}"
# echo "swapused=${swapused}"
# echo "swapfree=${swapfree}"
bogomips=$(lscpu | grep -i "bogomips" | \
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")
UCTdatetime=$(date -u "+%Y%m%d_%H%M")
dictsize=$(stat --printf="%s" /usr/share/dict/${language})
totsize=$(echo "${dictsize} * ${iterations}" | bc)
echo -n "Architecture|cores|CPU max MHz|"
echo -n "MEM Total|MEM Used|MEM Free|"
echo -n "SWAP Total|SWAP Used|SWAP Free|"
echo -n "OS|Bogomips|UCT Date|"
echo -n "Dictionary bytes|Iterations|"
echo -n "Cryptographic Hash|WallTime|UserTime|Systime|"
echo -n "MB/Sec Wall|MB/Sec User|MB/Sec System"
echo ""
echo -n "${Arch}|${cores}|${maxCPU}|"
echo -n "${memtotal}|${memused}|${memfree}|"
echo -n "${swaptotal}|${swapused}|${swapfree}|"
echo -n "$(func_os)|${bogomips}|${UCTdatetime}|"
echo -n "${dictsize}|${iterations}|"
echo -n "${hashprogram}|${elapsedseconds}|${userseconds}|"
echo -n "${systemseconds}|"
echo " ( ${dictsize} * ${iterations} ) / ${elapsedseconds}" | bc
echo " ( ${dictsize} * ${iterations} ) / ${userseconds}" | bc
echo " ( ${dictsize} * ${iterations} ) / ${systemseconds}" | bc
