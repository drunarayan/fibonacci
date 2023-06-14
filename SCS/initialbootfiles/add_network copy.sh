#!/bin/bash
DATESTR=`date +%m%d%y%H%M%S`
echo "" > verizon_network
echo 'network={' >> verizon_network
echo '	ssid="Verizon-MiFi8800L-849C"' >> verizon_network
echo '	psk="7a71eb72"' >> verizon_network
echo '	key_mgmt=WPA-PSK' >> verizon_network
echo '	priority=2' >> verizon_network
echo '}' >> verizon_network
echo "" >> verizon_network
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.$DATESTR
#sudo cat /etc/wpa_supplicant/wpa_supplicant.conf.$DATESTR
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf ./verizon_network > temp_network
sudo cp  temp_network /etc/wpa_supplicant/wpa_supplicant.conf
sudo cat /etc/wpa_supplicant/wpa_supplicant.conf
