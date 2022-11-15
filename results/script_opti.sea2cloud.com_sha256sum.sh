#!/bin/bash
# /home/rnovak/github/sysperf/results/script_opti.sea2cloud.com_sha256sum.sh
mcperf -r "/home/rnovak/github/sysperf/results" -c 1       -w 8 -n -s sha256sum 5Kib 
mcperf -r "/home/rnovak/github/sysperf/results" -c 512       -w 8 -n -s sha256sum 5Kib 
