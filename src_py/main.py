
# direct
import time
import json
import os
import psutil
# from
from io import FileIO
from pypresence import Presence
# custom
from classes.network import Network
from classes.multi_threading import myThread
from classes.discord_presence import Presence
from classes.event import Event
from classes.util import CountLines
from conf import config_json

# Create a new Presence
RPC = Presence(config_json['client_id'])
RPC.connect()

# Local Network for Studio's Plugin
LastDataRecieved = -1 # Last time data was recieved from studio
LatestData = None
ActiveNumberz = 0
# activeOutgoing = {
#     ScriptName = activeScript and activeScript.Name or false,
#     ScriptSource = activeScript and activeScript.Source or false,
#     ScriptFullName = activeScript and activeScript:GetFullName() or false,
#     PlaceName = game.Name,
#     PlaceID = game.PlaceId,
#     CreatorID = game.CreatorId,
#     CreatorType = game.CreatorType.Name,
#     ActiveTime = startActive,
# }

# Class
class PresenceNetworkHost(Network):
    def getReturnData(self, address, data):
        return super().getReturnData(address, data)
    def handleReceivedData(self, receieved_data):
        global LastDataTick, LatestData
        LastDataTick = time.time()
        LatestData = receieved_data or None
        print(LatestData)
        return super().handleReceivedData(receieved_data)
    def __init__(self, ports=None, ip=None, access_key=None):
        super().__init__(ports=ports, ip=ip, access_key=access_key)
    pass

# Functions
def SetBlankRPC() -> None:
    RPC.update(
        details = "Meditating in Roblox Studio.", 
        state = "Awaiting Connection.",
        start = int( time.time() ),
        large_image = "robloxstudioicon"
    )

def SetDataRPC() -> None:
    global LatestData
    RPC.update(
        details = 'Editing {}'.format(LatestData["ScriptName"]), 
        state = "Lines: {}".format(str( CountLines(LatestData["ScriptSource"]) )),
        start = LatestData['ActiveTime'],
        large_image = "robloxstudioicon"
    )

def UpdateRPC() -> None:
    global LatestData, ActiveNumberz, LastDataRecieved
    if (LatestData == None) or (LatestData["ScriptName"] == False):
        if ActiveNumberz != 1:
            ActiveNumberz = 1
            print("reset")
            SetBlankRPC()
        return
    if ActiveNumberz == LatestData["ScriptSource"]:
        return
    ActiveNumberz = LatestData["ScriptSource"]
    print("set")
    LastDataRecieved = time.time()
    SetDataRPC()

# Main
HostNetwork = PresenceNetworkHost( 
    ip = config_json['ip_address'], 
    ports = config_json['port_numbers'],
    access_key = config_json['hash_key']
)

while True:
    UpdateRPC()
    time.sleep(2)

# while True:  # The presence will stay on as long as the program is running
#     cpu_per = round(psutil.cpu_percent(), 1) # Get CPU Usage
#     mem = psutil.virtual_memory()
#     mem_per = round(psutil.virtual_memory().percent, 1)
#     print(RPC.update(large_image="robloxstudioicon", details="RAM: "+str(mem_per)+"%", state="CPU: "+str(cpu_per)+"%"))  # Set the presence
#     time.sleep(15) # Can only update rich presence every 15 seconds
