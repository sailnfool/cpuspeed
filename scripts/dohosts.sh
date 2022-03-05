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
declare -a hostnames
USAGE="Run the mcperf script on multipl machines\r\n
\t-h\t\tPrint this message\r\n
\t-o\t\tRun the test scripts ONLY on this machine\r\n
"

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
# Define all of the optionargs documented in USAGE.
########################################################################
optionargs="ho"

########################################################################
# Process the Command Line options based on the Usage above
########################################################################
while getopts ${optionargs} name
do
  case ${name} in
  h)
    echo -e ${USAGE}
    exit 0
    ;;
  o)
    thishost=$(hostname)
    hostnames=("${thishost}")
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


########################################################################
# Here is the script that will be run on each of the systems.
########################################################################
cat > ${scriptfile} << EOF
#!/bin/bash
if [[ ! -d /home/rnovak/github/sysperf ]]
then
	mkdir -p /home/rnovak/github
	cd /home/rnovak/github
	git clone git@github.com:sailnfool/sysperf.git
fi
cd ~rnovak/github/sysperf
git pull
sleep 3
make
cd ~rnovak/github/sysperf/results
rm *.csv *.txt *.sh
if [[ ! -d valid_results ]]
then
  mkdir valid_results
fi
if [[ ! -d working_scripts ]]
then
  mkdir working_scripts
fi
allwrapper
localscript=\$(echo "/tmp/script_\$(hostname)\$\$.sh")
echo "#!/bin/bash" > \${localscript}
for script in script*.sh
do
  echo "bash -x \${script}" >> \${localscript}
done
bash -x \${localscript} 2>&1 | tee /tmp/\$(hostname)_log_\$\$.txt &
EOF

########################################################################
# For each of hte systems we will execute the above generated scripts
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
  if [[ ! "${rhosts}" = "$(hostname)" ]]
  then
    echo Working on $i
    ssh ${USER}@${rhost} 'bash -s -x' ${scriptfile} &
  fi
done

########################################################################
# Now execute the script locally
########################################################################
bash -x ${scriptfile}
rm -f ${scriptfile}

