
# direct
import json
import os

__directory : str = '/'.join(__file__.split("\\")[0:-1])
__configFilePath : str = __directory + "./conf.json"

# Default Config
if not os.path.exists(__configFilePath):
    with open(__configFilePath, "a") as file:
        file.write("""{
            "client_id": "-1"
        }""")

# Load Configuration
config_json : json = None
with open(__directory + "./conf.json", "r") as file:
    config_json = json.loads( file.read() )
