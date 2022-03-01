#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# mcpuspeed - Collect relative performance data on CPU speed
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.4 | REN |02/28/2022| stripped the system information out of each
#                      | record and placed it into a separate file that
#                      | is written only once per host.  Redirected the
#                      | sleep message to stderr so it won't clutter
#                      | result files.  If there is a failure in 
#                      | timing the applications, put the word 
#                      | FAILURE at the beginning of the record.
# 1.3 | REN |02/25/2022| concatenate N copies of the dictionary file
#                      | together before starting to iterate the
#                      | cryptographic hashes over 1/Nth the number of
#                      | iterations.
# 1.2 | REN |02/20/2022| Track memory and swap usage as well as the
#                      | Date and time run
# 1.1 | REN |02/20/2022| Tweaked into a separate github repository
#                      | Added tracking of memory and swap as well as
#                      | a complete timestamp for each record created
#                      | Note that the timestamp is in UCT
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
########################################################################
source func.nice2num
source func.errecho
source func.insufficient
source func.toseconds
source func.os

########################################################################
# Set the # default values that can be overridden on the command lines.
########################################################################
numcopies=1
NUMARGS=1
FUNC_DEBUG="0"
verbosemode="FALSE"
export FUNC_DEBUG
dictpath=/usr/share/dict/
language=american-english
OUTFILE=/tmp/timer_out$$.txt
hashprogram=$(which sha256sum)
timerfailure="FALSE"
waitdivisor=8
resultdir=${HOME}/github/cpuspeed/results

USAGE="\r\n${scriptname} [-h] [-c <#>] [-l <language> ] [-n]\r\n
\t\t\t[-s <hashprogram>] [-w <#>] <nicenumber>\r\n
\t\tProvide a nicenumber to control the iterations of the number of\r\n
\t\ttimes that we take the sha256sum of the local dictionary.  This\t\n
\t\twill report the architecture of the machine, the size of the\r\n
\t\tdictionary, the number of iterations, bogomips, time per hashing\r\n
\t\t10Mib characters as normalization\r\n
\t<nicenumber>\tA number or a number in the format \"1M\" ori\r\n
\t\t\t\"1Mib\" to represent:\r\n
\t\t\t   1 M (Mbyte) ${__kbytesvalue["M"]}\r\n
\t\t\tor 1 Mib (Mbibyte) ${__kbibytesvalue["MIB"]}\r\n
\t\t\tor 1 Pib (Pbibyte) ${__kbibytesvalue["PIB"]}\r\n
\t\t\tor other bibyte prefix (e.g., eta or zeta)\r\n
\r\n
\t\t\tFor a complete table of nice suffixes and values\r\n
\t\t\t${scriptname} -v -h\r\n
\t-c\t<#>\tthe number of copies of the dictionary that are\r\n
\t\t\tconcatenated together to diminish the open/close processing\r\n
\t\t\tfor the opening and closing of the input file. The default\r\n
\t\t\tnumber of copies is ${numcopies}.  Suggested values are\r\n
\t\t\tbetween 128 and 512 copies.  See also -w below\r\n
\t-h\t\tPrint this message\r\n
\t-l\t\t<language>\tthe name of an alternate dictionary\r\n
\t-n\t\tSend the hash output to /dev/null\r\n
\t-r\t<dir>\tthe directory in which results are placed\r\n
\t-s\t<hashprogram>\tSpecify which cryptographic hash\r\n
\t\t\tprogram to use valid values:\r\n
\t\t\tb2sum; sha1sum; sha256sum; sha512sum\r\n
\t\t\tor the special case \"dd\" which helps measure\r\n
\t\t\tthe file operations (open, read, write)\r\n
\t\t\twithout the cryptographic processing\r\n
\t-v\t\tturn on verbose mode, currently ignored\r\n
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

########################################################################
# Define all of the optionargs documented in USAGE.
########################################################################
optionargs="c:hl:nr:s:vw:"

########################################################################
# Process the Command Line options based on the Usage above
########################################################################
while getopts ${optionargs} name
do
  case ${name} in
  c)
    if [[ "${OPTARG}" =~ $re_integer ]]
    then
      numcopies="${OPTARG}"
    else
      errorecho -e "-c requires an integer argument"
      errorecho -e ${USAGE}
      exit 1
    fi
    ;;
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
  r)
    if [[ -d "${OPTARG}" ]]
    then
      resultdir="${OPTARG}"
    else
      errecho -e "-r parameter ${OPTARG} is not a directory"
      errecho -e ${USAGE}
      exit 1
    fi
    ;;
  s)
    hashprogram="${OPTARG}"
    case ${hashprogram} in
      dd)
        hashprogram=$(which ${hashprogram})
        hashprogram=${hashprogram##*/}
        ;;
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
effiter=${POWER}
iterations=$(nice2num "${POWER}")
iterations=$((iterations / ${numcopies}))

########################################################################
# Create a shell script in /tmp which we will execute the test
# programs.
# the application script under test that invokes the test programs
# is referred to as TIMER_APP.
# The output of /usr/bin/time is captured in TIMER_OUT from which the
# Elapsed, User and System time spent in the TIMER_APP is extracted.
# The input file to the the test program is placed in TIMER_INPUT.
# Nominally this is the default language file in the dictionary path
# on this machine.  For American English, this is:
# /usr/share/dict/american-english.  Since this file can vary 
# according to the locale, the absolute times are normalized by 
# dividing the number of total bytes hashed by 1,000,000
########################################################################
TIMER_APP_DEV_NULL=/tmp/mctimer_null$$.sh
TIMER_APP_DD=/tmp/mctimer_dd$$.sh
TIMER_APP=/tmp/mctimer$$.sh
TIMER_OUT=/tmp/mctimeout$$.txt
TIMER_INPUT=/tmp/mctimein$$
rm -f ${TIMER_APP} ${TIMER_OUT} ${TIMER_INPUT} ${TIMER_APP_DEV_NULL} \
  ${TIMER_APP_DEV_NULL}

########################################################################
# In order to minimize the overhead for each test, if the copies of the
# dictionary have already been done, then just link the input file to
# that number of copies.  Otherwise we make the number of copies of the
# dictionary in /tmp and link that to the TIMER_INPUT
########################################################################
if [[ -r /tmp/${language}_${numcopies} ]]
then
  ln /tmp/${language}_${numcopies} ${TIMER_INPUT}
else
  for i in $(seq ${numcopies})
  do 
    cat ${dictpath}/${language} >> /tmp/${language}_${numcopies}
  done
  sleeptime=$((numcopies/waitdivisor))
  sleepmessage=$(echo "Sleeping for ${sleeptime} seconds to allow copy to complete")
  # stderrecho ${sleepmessage}
  if [[ "${sleeptime}" -ne "0" ]]
  then
    sleep ${sleeptime}
          # Observed behavior is that the first time the file is 
          # created it impacts the timing of the program under test
          # for large files, presumably waiting for this write
          # operation to finish. Experiment to find your system
          # quiesce time.
  fi
  ln /tmp/${language}_${numcopies} ${TIMER_INPUT}
fi

########################################################################
# If the OUTFILE is /dev/null we can eliminate the extra test steps
# we create two TIMER_APPs, one that handles the case that the output
# is NOT /dev/null and one that assumes that the output is sent to
# /dev/null and does less work.  This latter is most likely the one
# that will be used.
########################################################################
cat > ${TIMER_APP} <<EOF
#!/bin/bash
rm -f ${OUTFILE}
i=0
while [[ \${i} -lt ${iterations} ]]
do
  ${hashprogram} ${TIMER_INPUT} >> ${OUTFILE}
  i=\$((i+1))
done
rm -f ${OUTFILE}
exit 0
EOF
cat > ${TIMER_APP_DEV_NULL} <<EOFNULL
#!/bin/bash
i=0
while [[ \${i} -lt ${iterations} ]]
do
  ${hashprogram} ${TIMER_INPUT} >> ${OUTFILE}
  i=\$((i+1))
done
exit 0
EOFNULL
cat > ${TIMER_APP_DD} <<EOFDD
#!/bin/bash
i=0
while [[ \${i} -lt ${iterations} ]]
do
  ${hashprogram} status=none if=${TIMER_INPUT} of=${OUTFILE}
  i=\$((i+1))
done
exit 0
EOFDD

########################################################################
# Figure out which timer app we will run and install it as the 
# app to use.
########################################################################
if [[ "${hashprogram}" = "dd" ]]
then
  mv ${TIMER_APP_DD} ${TIMER_APP}
else
  rm -f ${TIMER_APP_DD}
	if [[ "${OUTFILE}" = "/dev/null" ]]
	then
	  mv ${TIMER_APP_DEV_NULL} ${TIMER_APP}
	else
	  rm -f ${TIMER_APP_DEV_NULL}
	fi
fi

########################################################################
# Make sure that the app we will be timing is executable and then
# run it, capturing the elapsed, user and system time with
# /usr/bin/time
########################################################################
chmod +x ${TIMER_APP}
/usr/bin/time ${TIMER_APP} 2> ${TIMER_OUT}
timeresult=$?

########################################################################
# At this point the test is completed.  Now we gather all of the 
# statistics and emit them to the results file.  If the timing failed
# then note that failure and modify the output line accordingly.
########################################################################
if [[ "${timeresult}" -ne 0 ]]
then
  # echo "Failure from /usr/bin/time ${TIMER_APP}."
  # echo "output in ${TIMER_OUT}"
  timerfailure="TRUE"
  # exit 1
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

########################################################################
# Collect the rest of the system data
########################################################################


########################################################################
# Find out the maximum frequency at which the processors run.  Although
# Transmeta failed as a CPU company, their legacy lives on by lowering
# the clock speed of cores that are essentially idle (hence part of
# the fallacy of using Bogomips as a performance metric).
########################################################################
host=$(hostname)
Arch=$(uname -m)
maxCPU=$(lscpu | grep  -i "CPU max MHz" | \
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")
cores=$(lscpu | grep -i "^CPU(s)" |
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")
memtotal=$(free -h | awk '/^Mem:/ {print $2}')
memused=$(free -h | awk '/^Mem:/ {print $3}')
memfree=$(free -h | awk '/^Mem:/ {print $4}')
swaptotal=$(free -h | awk '/^Swap:/ {print $2}')
swapused=$(free -h | awk '/^Swap:/ {print $3}')
swapfree=$(free -h | awk '/^Swap:/ {print $4}')
bogomips=$(lscpu | grep -i "bogomips" | \
  sed "s/^.*:[^0-9]*\([0-9\.][0-9\.]*\)/\1/")

########################################################################
# I know that it seems odd to always use UCT time rather than local
# time, but if the testing is done on machines in different time
# zones this will keep the testing times straight
########################################################################
UCTdatetime=$(date -u "+%Y%m%d_%H%M")
dictsize=$(stat --printf="%s" /usr/share/dict/${language})

########################################################################
# Note that in computing the totsize that we multiply by the number
# of copies so that the rate data is not skewed.
########################################################################
totsize=$(echo "${dictsize} * ${iterations} * ${numcopies}" | bc)
elapsedrate=$(echo "( ${totsize} / ${elapsedseconds} ) / 1000000" | bc)
userrate=$(echo "( ${totsize} / ${userseconds} ) / 1000000" | bc)
systemrate=$(echo "( ${totsize} / ${systemseconds} ) / 1000000" | bc)

########################################################################
rm -f ${TIMER_APP} ${TIMER_OUT} ${TIMER_INPUT}

########################################################################
# Remembering if the timing was a failure, add the word "FAILURE - " to
# the beginning of the result line.
########################################################################
if [[ "${timerfailure}" == "TRUE" ]]
then
  rm -f ${TIMER_APP} ${TIMER_OUT}
  echo -n "FAILURE|"
fi

sysdescription_file=${resultdir}/${host}_description.txt
resultfile=${resultdir}/${host}.${hashprogram}.${numcopies}.csv
########################################################################
# We emit the header line every time.  Although mildly redundant this
# can be elided either by a spreadsheet application or by using 
# sort -u to eiliminate the redundant copies
########################################################################
output_values="FALSE"
if [[ ! -r "${sysdescription_file}" ]]
then
	echo -n "Hostname|Architecture|cores|CPU max MHz|" > ${sysdescription_file}
	echo -n "MEM Total|MEM Used|MEM Free|" >> ${sysdescription_file}
	echo -n "SWAP Total|SWAP Used|SWAP Free|" >> ${sysdescription_file}
	echo -n "OS|OS_VERSION_ID|Bogomips" >> ${sysdescription_file}
	echo "" >> ${sysdescription_file}
  output_values="TRUE"
fi
echo -n "Hostname|UCT Date_time|" >> ${resultfile}
echo -n "Dictionary bytes|Effective Iterations|" >> ${resultfile}
echo -n "Iterations|Number of Copies|" >> ${resultfile}
echo -n "Total size|" >> ${resultfile}
echo -n "Cryptographic Hash|" >> ${resultfile}
echo -n "WallTime|UserTime|Systime|" >> ${resultfile}
echo -n "MB/Sec Wall|MB/Sec User|MB/Sec System" >> ${resultfile}
echo "" >> ${resultfile}

########################################################################
# Emit the actual data for this test.
########################################################################
if [[ "${output_values}" = "TRUE" ]]
then
	echo -n "${host}|${Arch}|${cores}|${maxCPU}|" >> ${sysdescription_file}
	echo -n "${memtotal}|${memused}|${memfree}|" >> ${sysdescription_file}
	echo -n "${swaptotal}|${swapused}|${swapfree}|" >> ${sysdescription_file}
	echo -n "$(func_os)|$(func_os_version_id)|${bogomips}" >> ${sysdescription_file}
	echo "" >> ${sysdescription_file}
fi
echo -n "${host}|${UCTdatetime}|" >> ${resultfile}
echo -n "${dictsize}|${effiter}|" >> ${resultfile}
echo -n "${iterations}|${numcopies}|" >> ${resultfile}
echo -n "${totsize}|" >> ${resultfile}
echo -n "${hashprogram}|" >> ${resultfile}
echo -n "${elapsedseconds}|${userseconds}|${systemseconds}|" >> ${resultfile}
echo -n "${elapsedrate}|${userrate}|${systemrate}" >> ${resultfile}
echo "" >> ${resultfile}
tail -1 ${resultfile}
rm -f ${TIMER_APP} ${TIMER_OUT} ${TIMER_INPUT} ${TIMER_APP_DEV_NULL} \
  ${TIMER_APP_DEV_NULL}
