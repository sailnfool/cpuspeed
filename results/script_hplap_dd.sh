#!/bin/bash
# /home/rnovak/github/cpuspeed/results/script_hplap_dd.sh
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s dd 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s dd 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s dd 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s dd 15Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 15Kib 
