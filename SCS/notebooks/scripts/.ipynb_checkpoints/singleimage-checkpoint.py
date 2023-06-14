#!/usr/bin/python3

def get_startframe(base, dirn):
    scr = script_dir+"/get_startframe.sh"
    return [scr,base,dirn]

def capture_image(deg, frm, base, dirn):
        pgm = "/usr/local/bin/libcamera-still"
        rot = "--rotation"
        rvl = deg 
        pre = "--nopreview" 
        fcs = "--autofocus"
        out = "--output" 
        ovl=dirn+"/"+base+"{:04d}.jpg".format(frm)
        return [pgm,rot,rvl,pre,fcs,out,ovl,fcs]

    
# Capture Single Image into a directory
import os, subprocess

home_dir = "/home/pi"
notes_dir = home_dir+"/notebooks"
script_dir = notes_dir+"/scripts"

basename = "image"
dirname = notes_dir+"/images"

cmd = get_startframe(basename, dirname)
output = subprocess.run(cmd, capture_output=True, text=True, check=True)
startframe = int(output.stdout)

rotation = "180"

cmd = capture_image(rotation, startframe, basename, dirname)
output = subprocess.run(cmd, capture_output=True, text=True, check=True)
