
# direct
import time
import json
import os
import psutil
# from
from io import FileIO
from pypresence import Presence
# custom
from utility.network import Network
from utility.multi_threading import myThread
from conf import config_json

# Create a new Presence
RPC = Presence(config_json['client_id'])
RPC.connect()

# Local Network for Studio's Plugin
LatestData = None
LatestDataTick = -1 # Last time data was recieved from studio

class PresenceNetworkHost(Network):
    def getReturnData(self, address, data):
        return super().getReturnData(address, data)
    def handleReceivedData(receieved_data):
        LastDataTick = time.time()
        LatestData = receieved_data
        return super().handleReceivedData()
    pass

HostNetwork = PresenceNetworkHost( 
    ip = config_json['ip_address'], 
    ports = config_json['port_numbers'],
    access_key = config_json['hash_key']
)

while True:
    if (time.time() - LastCheckTick) > 30:
        print("NO PRESENCE UPDATE RECIEVED FROM STUDIO, RESETTING")
        LastCheckTick = time.time()
        LatestData = None
    if LatestData != None:
        RPC.update(
            details = LatestData["upper_text"] or "",
            state = LatestData["lower_text"] or "",
            start = int( time.time() ),
            large_image = "robloxstudioicon"
        )
    else:
        RPC.update(
            details = "Meditating in Roblox Studio.", 
            state = "Awaiting Connection.",
            start = int( time.time() ),
            large_image = "robloxstudioicon"
        )
    time.sleep(15)

# while True:  # The presence will stay on as long as the program is running
#     cpu_per = round(psutil.cpu_percent(), 1) # Get CPU Usage
#     mem = psutil.virtual_memory()
#     mem_per = round(psutil.virtual_memory().percent, 1)
#     print(RPC.update(large_image="robloxstudioicon", details="RAM: "+str(mem_per)+"%", state="CPU: "+str(cpu_per)+"%"))  # Set the presence
#     time.sleep(15) # Can only update rich presence every 15 seconds
