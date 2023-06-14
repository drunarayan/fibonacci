#!/bin/bash
DATESTR=`date +%m%d%y%H%M%S`
echo "" > SSB_network
echo 'network={' >> SSB_network
echo '	ssid="SSB"' >> SSB_network
echo '	psk="ssb98122"' >> SSB_network
echo '	key_mgmt=WPA-PSK' >> SSB_network
echo '	priority=3' >> SSB_network
echo '}' >> SSB_network
echo "" >> SSB_network

sudo echo "-------- OLD NETWORK -------"
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.$DATESTR
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf.$DATESTR

sudo echo "-------- NEW NETWORK -------"
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf ./SSB_network > temp_network
sudo cp  temp_network /etc/wpa_supplicant/wpa_supplicant.conf
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf
