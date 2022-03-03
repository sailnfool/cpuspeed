#!/bin/bash
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 1Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 5Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 10Kib 
mcspeed -r "/home/rnovak/github/cpuspeed/results" -c 1       -w 8 -n -s dd 15Kib 
