#!/bin/bash
# /home/rnovak/github/cpuspeed/results/script_pi3_sha512sum.sh
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha512sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha512sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha512sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha512sum 15Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s sha512sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s sha512sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s sha512sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s sha512sum 15Kib 
