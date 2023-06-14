#!/bin/bash
# Script: bu_pi_temp.sh
# Purpose: Display the ARM CPU and GPU  temperature of Raspberry Pi 4 
# -------------------------------------------------------
cpu=$(</sys/class/thermal/thermal_zone0/temp)
echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
echo "GPU => $(/opt/vc/bin/vcgencmd measure_temp)"
echo "CPU => $((cpu/1000))'C"
