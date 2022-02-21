#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# wrapper_cpuspeed - generate a script that will repeatedly invoke a 
#                    list of hash functions with different repetition
#                    counts for the cpuspeed_function
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
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

UCTdatetime=$(date -u "+%Y%m%d_%R")
testname="$(hostname)_${UCTdatetime}"
maxiterations=50
iterincrement=10
########################################################################
# Process the command line options
########################################################################
USAGE="${0##*/} [-h] [-f <testname>i] [<maxiterations> [<increment>]]\r\n
\t\t<maxiterations> (default ${maxiterations})is the number\r\n
\t\tof times that the test is performed for each hashtype.  Note\r\n
\t\tis multiplied by 1024\r\n
\t\t<increment> (default ${iterincrement}) is the number of\r\n
\t\tof iterations to bump the test count by each time\t\n
\t\twhere <testname> (default ${testname}) is the name of the CSV\r\n
\t\tfile where the results are tabulated\r\n
"

optionargs="hf:"
NUMARGS=0 #No arguments are mandatory

while getopts ${optionargs} name
do
  case ${name} in
  h)
    echo -e ${USAGE}
    exit 0
    ;;
  f)
    testname="${OPTARG}"
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
rawout=${testname}.raw
scripter=script_$(hostname).sh
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
    echo "cpuspeed_function -n -s ${hashes[${myhash}]} ${count}Kib |" \
      "tee -a ${outdir}/${testoutput}" | tee -a ${outdir}/${scripter}
  done
  if [[ "${count}" -eq "1" ]]
  then
    count=$((count+(iterincrement-1)))
  else
    count=$((count+iterincrement))
  fi
done
exit 1

# bash ${outdir}/${scripter} | tee ${tmpdir}/${rawout}
# cat ${tmpdir}/${rawout}  sed "s/|/ /g" tee -a ${outfile}
# sort -u < ${outfile} > ${outdir}/sorted.${testoutput}
