#!/bin/bash
scriptname=${0##*/}
####################
# Copyright (c) 2019 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# primes - Generate a list of prime numbers in a range of numbers
#          Primes are listed as a number followed by a new line
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.0 | REN |03/19/2022| Initial Release
#_____________________________________________________________________
#
source func.errecho
source func.nice2num
source func.insufficient
source func.regex

USAGE="\r\n${scriptname} [ -hv ] <lo#> <hi#>\r\n
\t\tThis program generates a list of prime number in the interval\r\n
\t\t<lo#> to <hi#>.  The low numbers and high numbers can be\r\n
\t\texpressed as integers or as \"nice\" numbers, e.g. 1M for one\r\n
\t\tmegabyte and 1MiB for one mebibyte (1024*1024)\r\n
\t-h\t\tPrint this help information\r\n
\t-v\t\tWhen used with -h will print a table of nice numbers\r\n
"

optionargs="hv"
NUMARGS=2
lowprime=1
highprime=100

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

if [[ "$#" -lt ${NUMARGS} ]]
then
  insufficient "${NUMARGS} $@"
  errecho "-e" "${USAGE} $@"
  exit -2
fi

########################################################################
# Process the positional arguments lowprime and highprime
########################################################################
if [[ "$#" -ge "1" ]]
then
  if [[ "$1" =~ $re_integer ]]
  then
    lowprime=$1
  else
    if [[ "$1" =~ $re_nicenumber ]]
    then
      lowprime=$(nice2num "$1")
    else
      errecho "-e" "Bad nicenumber $1"
      errecho "-e" ${USAGE} $@
      exit -3
    fi
  fi
  shift
fi

if [[ "$#" -ge "1" ]]
then
  if [[ "$1" =~ $re_integer ]]
  then
    highprime=$1
  else
    if [[ "$1" =~ $re_nicenumber ]]
    then
      highprime=$(nice2num "$1")
    else
      errecho "-e" "Bad nicenumber $1"
      errecho "-e" ${USAGE} $@
      exit -3
    fi
  fi
  shift
fi

declare -a pastprimes

pastprimes[0]=1
pastprimes[1]=2
maxprimeindex=1

startprime=1
candidate=2
while [[ ${candidate} -le ${highprime} ]]
do
	if [[ ${candidate} -le 2 ]]
	then
    if [[ "${candidate}" -ge "${lowprime}" ]]
    then
      echo "${candidate}"
    fi
    ((candidate++))
	  continue
	fi
  
  notprime="FALSE"
  primeindex=${startprime}
  divisor=pastprimes[${primeindex}]

  # First we check all pastprimes
  while [[ ${primeindex} -le ${maxprimeindex} ]]
  do
    # Work through the list of past primes
    divisor=${pastprimes[${primeindex}]}
    if [[ "$((candidate % divisor))" -eq 0 ]]
    then
      notprime="TRUE"
      break
    fi
    ((primeindex++))
  done

  if [[ "${notprime}" = "TRUE" ]]
  then
    ((candidate++))
    continue
  fi
  # Still don't know if it is prime or not.  We have to check all
  # the numbers between the largest known prime and the lowprime
  # we are testing.

  ((divisor++))

	while [[ ${divisor} -lt ${candidate} ]]
  do
    if [[ "$((candidate % divisor))" -eq 0 ]]
    then
      notprime="TRUE"
      break
    fi
    ((divisor++))
  done

  if [[ "${notprime}" = "TRUE" ]]
  then
    ((candidate++))
    continue
  fi

  # We have a prime number, add it to the past primes array
  ((maxprimeindex++))
  pastprimes[${maxprimeindex}]=${candidate}

  # If the prime just found is larger than the lowprime requested
  # then we print it.
  if [[ "${candidate}" -ge "${lowprime}" ]]
  then
    echo "${candidate}"
  fi
  ((candidate++))
done
