#!/bin/bash
# /home/rnovak/github/sysperf/results/script_opti.sea2cloud.com_b2sum.sh
mcperf -r "/home/rnovak/github/sysperf/results" -c 1       -w 8 -n -s b2sum 5Kib 
mcperf -r "/home/rnovak/github/sysperf/results" -c 512       -w 8 -n -s b2sum 5Kib 
