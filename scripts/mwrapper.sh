#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# mwrapper - generate a script that will repeatedly invoke a
#            list of hash functions with different repetition
#            counts for the mcspeed script which includes not
#            only hash functions but can invoke dd to look at
#            subtracting the I/O overhead from the hash
#            computation.
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.1 | REN |02/24/2022| Added a parameter to override the date stamp
#                      | placed on the results csv file.
# 1.0 | REN |02/20/2022| Initial Release
#_____________________________________________________________________
########################################################################
source func.kbytes
source func.nice2num
source func.errecho
source func.insufficient
source func.regex

########################################################################
# Declare the list of default hash functions that will be tested
########################################################################
declare -a hashes
hashes=("b2sum" "sha1sum" "sha256sum" "sha512sum")

########################################################################
# Verify that binaries for each of the hash functions are found on 
# this machine
########################################################################
for myhash in "${!hashes[@]}"
do
  if [[ ! $(which ${hashes[${myhash}]}) ]]
  then
    errecho "-e" "Cryptographic Hash Function ${hashes[${myhash}]} not found"
    errecho "-e" "Have you installed the \"coreutils\" package?"
    sudo apt install coreutils
  fi
done
if [[ ! $(which time) ]]
then
  errecho "-e" "/usr/bin/time not found"
  errecho "-e" "Have you installed the time package?"
  sudo apt install time
fi

UCTdatetime=$(date -u "+%Y%m%d_%H%M")
testname="$(hostname)_${UCTdatetime}"
maxiterations=50
iterincrement=10
numcopies=512
waitdivisor=8
suffix=${UCTdatetime}
########################################################################
# Process the command line options
########################################################################
USAGE="${0##*/} [-h] [-c <#>] [-w <#>] [-d <suffix>] [-f <testname>i] [-n]\r\n
\t\t\t[<maxiterations> [<increment>]]\r\n
\t\t<maxiterations> (default ${maxiterations})is the number\r\n
\t\tof times that the test is performed for each hashtype.  Note\r\n
\t\tis multiplied by 1024\r\n
\t\t<increment> (default ${iterincrement}) is the number of\r\n
\t\tof iterations to bump the test count by each time\t\n
\t-c\t<#>\tThe number of copies of the input file to concatenate\r\n
\t\t\ttogether to minimize the open/close overhead.\r\n
\t-d\t<suffix>\tis the string just prior to the ".csv" extension\r\n
\t\t\tthat can uniquely identify the generate script.  The \r\n
\t\t\tdefault is normally the current date time \r\n
\t\t\t(e.g. ${UCTdatetime})\r\n
\t-f\t<testname> (default ${testname}) is \r\n
\t\t\tthe name of the CSV file where the results are\r\n
\t\t\ttabulated.\r\n
\t-h\t\tOutput this message\r\n
\t-n\t\tSend the hash output to /dev/null\r\n
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

optionargs="c:d:hf:nw:"
NUMARGS=0 #No arguments are mandatory

while getopts ${optionargs} name
do
  case ${name} in
  c)
    if [[ "${OPTARG}" =~ ${re_integer} ]]
    then
      numcopies="${OPTARG}"
    else
      errecho -e "-c requires an integer argument"
      errecho -e ${USAGE}
      exit 1
    fi
    ;;
  d)
    suffix="${OPTARG}"
    testname="$(hostname)_${suffix}"
    ;;
  h)
    echo -e ${USAGE}
    exit 0
    ;;
  f)
    testname="${OPTARG}"
    ;;
  n)
    OUTFILE="/dev/null"
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
# Even though the current incarnation has no required arguments, this
# code will save time later if we have required arguments
########################################################################
if [[ "$#" -lt ${NUMARGS} ]]
then
  errecho "-e" ${USAGE} $@
  insufficient ${NUMARGS} $@
  exit -2
fi

########################################################################
# Process the optional argument max iterations which is the number of
# iterations of the dictionary that will be hashed.  The iteration
# number is multiplied by 1024
########################################################################
if [[ "$#" -ge "1" ]]
then
  if [[ "$1" =~ $re_integer ]]
  then
    maxiterations=$1
  else
    errecho "-e" "<maxiterations> must be an integer"
    errecho "-e" ${USAGE}
    exit 1
  fi
  shift
fi

########################################################################
# Process the increment between interations trials.  Note that we start
# increments at 1, the second increment is increment - 1, so if
# increment were 10, the sequence would be 1, 10, 20...  If it were 5
# the sequence would be 1, 5, 10, 15....
########################################################################
if [[ "$#" -ge "1" ]]
then
  if [[ "$1" =~ $re_integer ]]
  then
    iterincrement=$1
  else
    errecho "-e" "<iterincrement> must be an integer"
    errecho "-e" ${USAGE}
    exit 1
  fi
  shift
fi

########################################################################
# We want to keep the results in the repository
########################################################################
outdir=$HOME/github/cpuspeed/results
testoutput=${testname}.csv
scripter=script_${testname}.sh
outfile=${outdir}/${testoutput}
max=${maxiterations}

########################################################################
# This is where we generate the bash command lines to invoke the test 
# function a number of times against a dictionary.  Note that we not
# only generate a given number of iterations, but we repeat that for
# each type of cryptographic hash that we know about.
# The output of this command is suitable for piping into bash or for
# placing in a file to be executed later.
########################################################################
rm -f ${outdir}/${scripter} ${outfile} ${outdir}/sorted.${testoutput}
echo "#!/bin/bash" | tee -a ${outdir}/${scripter}
count=1
while [[ ${count} -le ${max} ]]
do
  for myhash in "${!hashes[@]}"
  do
    echo "mcspeed -c ${numcopies} -w ${waitdivisor} -n -s ${hashes[${myhash}]} ${count}Kib |" \
      "tee -a ${outdir}/${testoutput}" | tee -a ${outdir}/${scripter}
  done
  if [[ "${count}" -eq "1" ]]
  then
    count=$((count+(iterincrement-1)))
  else
    count=$((count+iterincrement))
  fi
done
exit 0