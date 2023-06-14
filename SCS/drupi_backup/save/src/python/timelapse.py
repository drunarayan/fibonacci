import socket
import datetime
from time import sleep
from picamera import PiCamera
from os import system

thishost = socket.gethostname()

camera = PiCamera()
camera.resolution = (1024, 768)
bupidir = "/home/pi/" + thishost
i = 0
with open(bupidir+'/cpu_temp.txt', 'w+') as f:
    while True:
        i += 1
        sleep(5)
        camera.capture(bupidir+'/images/image{0:04d}.jpg'.format(i))
        with open('/sys/class/thermal/thermal_zone0/temp') as temp:
                curCtemp = float(temp.read()) / 1000
                curFtemp = ((curCtemp / 5) * 9) + 32
        string_to_print = "The time stamp is %s The CPU Temp is %3.1f\n" % (str(datetime.datetime.now()),curCtemp)
        print(string_to_print)
        f.write(string_to_print)

f.close()

