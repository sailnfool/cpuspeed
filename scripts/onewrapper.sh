#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2020 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# onewrapper - generate a script that will repeatedly invoke a
#              list of hash functions with different repetition
#              counts for the mcspeed script which includes not
#              only hash functions but can invoke dd to look at
#              subtracting the I/O overhead from the hash
#              computation.
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.2 | REN |03/11/2022| made -l to start at a different low value
#                      | than 1.  Testing has shown that the MBytes/sec
#                      | has been stable across iteration counts.  This
#                      | allows you to reduce the number of iterations
#                      | actually tested
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
hashes=("b2sum" "sha1sum" "sha256sum" "sha512sum" "dd")

########################################################################
# Verify that binaries for each of the hash functions are found on 
# this machine.  Note that this test is also done for "dd" but it 
# would be sacrilege to not find "dd" on a machine interesting enough
# to test.
########################################################################
for myhash in "${hashes[@]}"
do
  if [[ ! $(which ${myhash}) ]]
  then
    errecho "-e" "Cryptographic Hash Function ${myhash} not found"
    errecho "-e" "Have you installed the \"coreutils\" package?"
    sudo apt install coreutils
  fi
done

########################################################################
# It turns out that /usr/bin/time is not installed by default on all
# systems.
########################################################################
if [[ ! $(which time) ]]
then
  errecho "-e" "/usr/bin/time not found"
  errecho "-e" "Have you installed the time package?"
  sudo apt install time
fi

########################################################################
# We use the Universal Coordinated Time (AKA Greenwich time) to allow
# for the fact that some remote machines might be in different time
# zones.
########################################################################
UCTdatetime=$(date -u "+%Y%m%d_%H%M")
testname="$(hostname)_${UCTdatetime}"
maxiterations=50
iterincrement=10
miniterations=1
numcopies=512
waitdivisor=8
suffix=${UCTdatetime}
########################################################################
# Process the command line options
########################################################################
USAGE="${0##*/} [-h] [-c <#>] [-l <#>] [-w <#>] [-d <suffix>] [-f <testname>i] [-n]\r\n
\t\t\t[<maxiterations> [<increment>]]\r\n
\t\t<maxiterations> (default ${maxiterations})is the number\r\n
\t\tof times that the test is performed for each hashtype.  Note\r\n
\t\tis multiplied by 1024\r\n
\t\t<increment> (default ${iterincrement}) is the number of\r\n
\t\tof iterations to bump the test count by each time\t\n
\t-c\t<#>\tThe number of copies of the input file to concatenate\r\n
\t\t\ttogether to minimize the open/close overhead.\r\n
\t\t\tNote: the number of copies is appended to the\r\n
\t\t\tsuffix in order to distinguish both scripts\r\n
\t\t\tand results.\r\n
\t-d\t<suffix>\tis the string just prior to the ".csv" extension\r\n
\t\t\tthat can uniquely identify the generate script.  The \r\n
\t\t\tdefault is normally the current date time \r\n
\t\t\t(e.g. ${UCTdatetime})\r\n
\t-f\t<testname> (default ${testname}) is \r\n
\t\t\tthe name of the CSV file where the results are\r\n
\t\t\ttabulated.\r\n
\t-h\t\tOutput this message\r\n
\t-l\t<#>\tStart the number of iterations at this value instead of one.
\t-n\t\tSend the hash output to /dev/null\r\n
\t-s\t<hashprogram>\tSpecify which cryptographic hash\r\n
\t\t\tprogram to use valid values:\r\n
\t\t\tb2sum; sha1sum; sha256sum; sha512sum\r\n
\t\t\tor the special case \"dd\" which helps measure\r\n
\t\t\tthe file operations (open, read, write)\r\n
\t\t\twithout the cryptographic processing\r\n
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

optionargs="c:d:hf:l:ns:w:"
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
    OUTFILE="/dev/null"
    ;;
  s)
    hashprogram="${OPTARG}"
    case ${hashprogram} in
      dd)
        hashprogram=$(which ${hashprogram})
        if [[ ! $? ]]
        then
          errecho -e "${hashprogram} not found"
          errecho -e ${USAGE}
          exit 1
        fi
        hashprogram=${hashprogram##*/}
        hashes+=("dd")
        ;;
       b2sum)
        hashprogram=$(which ${hashprogram})
        if [[ ! $? ]]
        then
          errecho -e "${hashprogram} not found"
          errecho -e ${USAGE}
          exit 1
        fi
        hashprogram=${hashprogram##*/}
        ;;
      sha1sum)
        hashprogram=$(which ${hashprogram})
        if [[ ! $? ]]
        then
          errecho -e "${hashprogram} not found"
          errecho -e ${USAGE}
          exit 1
        fi
        hashprogram=${hashprogram##*/}
        ;;
      sha256sum)
        hashprogram=$(which ${hashprogram})
        if [[ ! $? ]]
        then
          errecho -e "${hashprogram} not found"
          errecho -e ${USAGE}
          exit 1
        fi
        hashprogram=${hashprogram##*/}
        ;;
      sha512sum)
        hashprogram=$(which ${hashprogram})
        if [[ ! $? ]]
        then
          errecho -e "${hashprogram} not found"
          errecho -e ${USAGE}
          exit 1
        fi
        hashprogram=${hashprogram##*/}
        ;;
      \?)
        errecho "-e" "Invalid hash program: ${OPTARG}"
        errecho "-e" ${USAGE}
        exit 2
    esac
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
# a small cleanup.  During testing I realized that both the shell
# scripts and the results files needed the numcopies appended to
# the names to make sure all variants were run.
# Later amended to remove the numcopies from the names.
########################################################################

########################################################################
# We want to keep the results in the repository
########################################################################
outdir=$HOME/github/sysperf/results
testoutput=${testname}.csv
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
rm -f ${outfile} ${outdir}/sorted.${testoutput}

########################################################################
# The following kludge is to eliminate any old scriptfiles laying
# around for this particular test.
########################################################################
count=${miniterations}
while [[ ${count} -le ${max} ]]
do
  for myhash in "${hashes[@]}"
  do
    testname="$(hostname)_${myhash}"
    scriptfile=script_${testname}.sh
    if [[ ! -r "${outdir}/${scriptfile}" ]]
    then

      ##################################################################
      # generate the scriptfile for a particular hash (or dd)
      ##################################################################
      echo "#!/bin/bash" | tee -a ${outdir}/${scriptfile}
      echo "# ${outdir}/${scriptfile}" | tee -a ${outdir}/${scriptfile}
    fi
    echo "mcperf -r \"${outdir}\" -c ${numcopies} \
      -w ${waitdivisor} -n -s ${myhash} ${count}Kib " \
      | tee -a ${outdir}/${scriptfile}
  done

  ######################################################################
  # Handle the boundary case of 1 to 5 instead of going from 1 to 6
  ######################################################################
  if [[ "${count}" -eq "1" ]]
  then
    count=$((count+(iterincrement-1)))
  else
    count=$((count+iterincrement))
  fi
done
exit 0
