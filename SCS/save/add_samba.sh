#!/bin/bash
DATESTR=`date +%m%d%y%H%M%S`
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y samba samba-common-bin
mkdir /home/pi/shared
echo '' > add_share
echo '[pishared]' >> add_share
echo 'path = /home/pi/shared' >> add_share
echo 'writeable=Yes' >> add_share
echo 'create mask=0777' >> add_share
echo 'directory mask=0777' >> add_share
echo 'public=no' >> add_share
echo '' >> add_share
#
if [ -f '/etc/samba/smb.conf' ]; then
	sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.$DATESTR
	sudo cat /etc/samba/smb.conf /etc/samba/smb.conf ./add_share > temp_share
	sudo cp  temp_share /etc/samba/smb.conf
	sudo cat /etc/samba/smb.conf
	echo -e "raspberry\nraspberry\n" | sudo smbpasswd -a pi
	sudo systemctl restart smbd
else
	echo 'samba does not appear to be installed'
fi