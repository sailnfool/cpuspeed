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
# 1.1 | REN |03/11/2022| Onewrapper added a -l so we can start at a 
#                      | larger number of iterations than 1.  Testing
#                      | has shown that the MBytes/sec is stable across
#                      | all values from 1 to 15+.  This should
#                      | dramatically reduce testing time
# 1.0 | REN |02/28/2022| Initial Release
#_____________________________________________________________________
########################################################################
source func.errecho

if [[ $(which onewrapper) ]]
then

  ######################################################################
  # Create a set of shell scripts where the count of the number of
  # copies of the dictionary (-c 1) is given and the scripts will test
  # from one to 15K copies in increments of 5K
  ######################################################################
  primename="script_$(hostname)_primes.sh"
  resultdir="~/github/sysperf/results"
  onewrapper -c 1 -l 5 5 5
  onewrapper -c 512 -l 5 5 5
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
