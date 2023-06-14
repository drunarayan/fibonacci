#!/bin/bash

sudo apt-get update
sudo apt-get upgrade

sudo apt install -y python3-libcamera 
sudo apt install -y python3-kms++
sudo apt install -y python3-pyqt5 
sudo apt install -y python3-prctl 
sudo apt install -y libatlas-base-dev 
sudo apt install -y ffmpeg 
sudo apt install -y libopenjp2-7 
sudo apt install -y python3-pip
pip3 install numpy --upgrade
#pip3 install picamera2
NOGUI=1 pip3 install git+https://github.com/raspberrypi/picamera2.git

sudo apt install -y python3-opencv
sudo apt install -y opencv-data

pip3 install tflite-runtime

cd /home/pi

git clone https://github.com/raspberrypi/picamera2.git

cp -R picamera2 notebooks

sudo reboot now

