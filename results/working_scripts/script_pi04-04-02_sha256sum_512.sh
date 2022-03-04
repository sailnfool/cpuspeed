#!/bin/bash
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha256sum 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha256sum 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha256sum 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 512       -w 8 -n -s sha256sum 15Kib 
