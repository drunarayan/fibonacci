import socket
import os
import time
from datetime import datetime
#
thishost = socket.gethostname()
now = datetime.now()
#print("host_%s_booted_%s" % (thishost,now.strftime("%y%m%d%H%M%S")))
#print("host_{}_booted_{}".format(thishost,now.strftime("%y%m%d%H%M%S")))
#print("/tmp/host_{}_booted_{}".format(thishost,now.strftime("%y%m%d%H%M%S")))
os.mknod("/tmp/host_{}_booted_{}".format(thishost,now.strftime("%y%m%d%H%M%S")))
