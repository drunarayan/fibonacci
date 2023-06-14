#!/bin/bash
sudo apt-get update
sudo apt-get install python3-pip
sudo pip3 install setuptools
sudo apt install libffi-dev
sudo pip3 install cffi
sudo pip3 install jupyterlab
mkdir notebooks
sudo cp jupyter.service /etc/systemd/system
sudo systemctl enable jupyter.service
sudo systemctl daemon-reload
sudo systemctl start jupyter.service
jupyter notebook --generate-config
jupyter server password
