#!/bin/bash
echo "CURRENT TIME = "`date`
echo "HOSTNAME = "`hostname`
echo "USER id = "`whoami`
echo "IP ADDRESS = "`ip a s | grep "inet " | grep "dynamic" | cut -f6 -d" "`
