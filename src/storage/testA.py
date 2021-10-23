
# from
from io import FileIO
from pypresence import Presence
# direct
import time
import socket
import json
import os
import psutil

# Directories
directory : str = '/'.join(__file__.split("\\")[0:-1])
configFilePath : str = directory + "./conf.json"

# Default Config
if not os.path.exists(configFilePath):
    with open(configFilePath, "a") as file:
        file.write("""{
            "client_id": "-1"
        }""")

# Load Configuration
config_json : json = None
with open(directory + "./conf.json", "r") as file:
    config_json = json.loads( file.read() )
client_id : str = config_json['client_id']

# Create a new Presence
RPC = Presence(client_id)
RPC.connect()

while True:  # The presence will stay on as long as the program is running
    cpu_per = round(psutil.cpu_percent(), 1) # Get CPU Usage
    mem = psutil.virtual_memory()
    mem_per = round(psutil.virtual_memory().percent, 1)
    print(RPC.update(large_image="robloxstudioicon", details="RAM: "+str(mem_per)+"%", state="CPU: "+str(cpu_per)+"%"))  # Set the presence
    time.sleep(15) # Can only update rich presence every 15 seconds