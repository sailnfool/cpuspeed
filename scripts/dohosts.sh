#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2022 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# dohosts - for a set of hosts, run the complete set of performance
#           tests based on cryptographic hashes.
# Author - Robert E. Novak aka REN
#	sailnfool@gmail.com
#	skype:sailnfool.ren
# License CC by Sea2Cloud Storage, Inc.
# see https://creativecommons.org/licenses/by/4.0/legalcode
# for a complete copy of the Creative Commons Attribution license
#_____________________________________________________________________
# Rev.|Auth.| Date     | Notes
#_____________________________________________________________________
# 1.0 | REN |03/04/2022| Initial Release
#_____________________________________________________________________
#
scriptfile=/tmp/doscripts_$$.sh
cat > ${scriptfile} << EOF
#!/bin/bash
if [[ ! -d /home/rnovak/github/mcperf ]]
cd ~rnovak/github/cpuspeed
git pull
sleep 3
make
cd ~rnovak/github/cpuspeed/results
rm *.csv *.txt *.sh
mkdir valid_results working_scripts
awrapper
for script in script*.sh
do
  bash -x \${script}
done
EOF
# for i in optiplex980 inspiron3185 hplap lr br pi3
# do
#   echo Working on $i
#   ssh ${USER}@$i 'bash -s -x' ${scriptfile} &
# done
bash -x ${scriptfile}
rm -f ${scriptfile}

