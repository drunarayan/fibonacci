#!/bin/bash
# Script: bupi_takepics.sh
# Purpose: take a few pics
# -------------------------------------------------------
echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
raspistill -t 5000 -tl 2000 -o $HOME/$(hostname)/images/image%02d.jpg
