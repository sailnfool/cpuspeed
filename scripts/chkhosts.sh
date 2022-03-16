#!/bin/bash
scriptname=${0##*/}
########################################################################
# Copyright (c) 2022 Sea2Cloud Storage, Inc.  All Rights Reserved
# Modesto, CA 95356
#
# chkhosts - for a set of hosts, verify that you can login
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
declare -a hostnames

########################################################################
# add the systems to the list one at a time.  This makes adding a 
# single system later an easier process.
########################################################################
hostnames=("opti.sea2cloud.com")
hostnames+=("Inspiron3185")
hostnames+=("hplap")
hostnames+=("PI04-04-02")
hostnames+=("PI04-08-03")
hostnames+=("pi3")

########################################################################
# For each of the systems we will execute the above generated scripts
# Note that the locally generated script is run as a background task
# to insure that it can continue to run.  Note that the output of
# the background script is sent to /tmp/hostname_log_$$.txt so that
# we are able to run a shell on each host and peform "tail -f" on the
# file to monitor the progress on the remote host.
########################################################################
for rhost in "${hostnames[@]}"
do
  ######################################################################
  # Make sure we don't ssh to the local host we treat this case later
  ######################################################################
  if [[ ! "${rhost}" = "$(hostname)" ]]
  then
    echo Working on $i
    ssh ${USER}@${rhost} 
  fi
done

