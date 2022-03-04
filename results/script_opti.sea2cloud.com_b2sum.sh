#!/bin/bash
# /home/rnovak/github/cpuspeed/results/script_opti.sea2cloud.com_b2sum.sh
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 15Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s b2sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s b2sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s b2sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s b2sum 15Kib 
