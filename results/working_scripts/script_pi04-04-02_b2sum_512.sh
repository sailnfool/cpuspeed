#!/bin/bash
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s b2sum 15Kib 
