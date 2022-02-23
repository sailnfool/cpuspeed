#!/bin/bash

declare -a fieldnames=( \
 "Architecture" "cores" "CPU max MHz" \
 "MEM Total" "MEM Used" "MEM Free" \
 "SWAP Total" "SWAP Used" "SWAP Free" \
 "OS" "Bogomips" "UCT Date" \
 "Dictionary bytes" "Iterations" \
 "Cryptographic Hash" "WallTime" "UserTime" "Systime" \
 "MB/Sec Wall" "MB/Sec User" "MB/Sec System" )
	linesread=0
	OLDIFS=$IFS
	IFS="|"

	while read -r band default percent
	do
		####################
		# Skip the title line
		####################
		if [ ! "$band" = "BAND" ]
		then
			export PROC_BAND=${band}
			export DEFAULT_MS=${default}
			export FAIL_PERCENT=${percent}
		fi
		((++linesread))
	done < "${procdefault_file}"
	IFS=$OLDIFS

echo -n "Architecture|cores|CPU max MHz|"
echo -n "MEM Total|MEM Used|MEM Free|"
echo -n "SWAP Total|SWAP Used|SWAP Free|"
echo -n "OS|Bogomips|UCT Date|"
echo -n "Dictionary bytes|Iterations|"
echo -n "Cryptographic Hash|WallTime|UserTime|Systime|"
echo -n "MB/Sec Wall|MB/Sec User|MB/Sec System"
echo ""
echo -n "${Arch}|${cores}|${maxCPU}|"
echo -n "${memtotal}|${memused}|${memfree}|"
echo -n "${swaptotal}|${swapused}|${swapfree}|"
echo -n "$(func_os)|${bogomips}|${UCTdatetime}|"
echo -n "${dictsize}|${iterations}|"
echo -n "${hashprogram}|${elapsedseconds}|${userseconds}|"
echo -n "${systemseconds}|"
echo " ( ${dictsize} * ${iterations} ) / ${elapsedseconds}" | bc
echo " ( ${dictsize} * ${iterations} ) / ${userseconds}" | bc
echo " ( ${dictsize} * ${iterations} ) / ${systemseconds}" | bc
