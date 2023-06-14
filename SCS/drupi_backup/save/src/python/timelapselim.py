import socket
import datetime
from time import sleep
from picamera import PiCamera
from os import system

thishost = socket.gethostname()

camera = PiCamera()
camera.resolution = (1024, 768)
#camera.vflip = True
camera.hflip = True
bupidir = "/home/pi/" + thishost
i = 0
with open(bupidir+'/cpu_temp.txt', 'w+') as f:
    while True:
        if i == 2:
		i = 1
	else:
		i += 1
		
        sleep(5)
	image_name = '/images/image{0:04d}.jpg'.format(i)
        camera.capture(bupidir+image_name)
        with open('/sys/class/thermal/thermal_zone0/temp') as temp:
                curCtemp = float(temp.read()) / 1000
                curFtemp = ((curCtemp / 5) * 9) + 32
	string_to_print = "Taking image %s at %s with CPU Temp %3.1f\n" % (image_name,str(datetime.datetime.now()),curCtemp)
        #string_to_print = "The time stamp is %s The CPU Temp is %3.1f\n" % (str(datetime.datetime.now()),curCtemp)
        print(string_to_print)
        f.write(string_to_print)

f.close()

