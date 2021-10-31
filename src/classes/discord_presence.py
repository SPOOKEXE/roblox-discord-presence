
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
from conf import config_json

# Create a new Presence
class discord_presence:
    # connection to discord
    client_id : str = ""
    presence_class : Presence = None
    # actual presence data
    details : str = "Awaiting Setup" # upper text
    state : str = "No State Set." # lower text
    timestamp : int = -1
    small_icon = "robloxstudioicon"
    large_icon = "robloxstudioicon"

    def __update(self) -> None:
        self.presence_class.update(
            details = self.details or None,
            state = self.state or None,
            start = self.timestamp or None,
            small_image = self.small_icon or None,
            large_image = self.large_icon or None
        )
    
    def restart_timestamp(self, custom_time : int or None):
        self.timestamp = (custom_time == None) and int( time.time() ) or custom_time
    def set_upper_text(self, new_text : str = "unknown") -> None:
        details = new_text
    def set_lower_text(self, new_text : str = "unknown") -> None:
        self.state = new_text
    def set_small_icon(self, new_icon : str = "unknown") -> None:
        self.small_icon = new_icon
    def set_large_icon(self, new_icon : str = "unknown") -> None:
        self.large_icon = new_icon

    def __init__(self, client_id = "nil") -> None:
        self.client_id = client_id
        self.presence_class = Presence(self.client_id)
        self.presence_class.connect()
        self.restart_timestamp()
        self.__update()
    pass
