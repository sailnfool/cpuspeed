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
# 1.0 | REN |02/28/2022| Initial Release
#_____________________________________________________________________
########################################################################
source func.errecho

if [[ $(which mwrapper) ]]
then
  mwrapper -c 512 15 5
  mwrapper -c 1 15 5
else
  errecho -e "cannot find mwrapper.  Did you run make install?"
fi
