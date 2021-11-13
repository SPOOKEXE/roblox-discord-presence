import random

class Event:
    id = None
    __callback_array = []
    
    # PRIVATE
    def __remove(self, func):
        self.__callback_array.remove(func)
    
    def __add(self, func):
        self.__callback_array.append(func)
        return lambda func : self.remove(func)
    
    # PUBLIC
    def fire(self, arg):
        for callback in self.__callback_array:
            callback(arg)
            
    def event(self, callback):
        return self.__add(callback)
    
    def disconnect(self):
        self.__callback_array = None
        self.id = None
        self = None
    
    def __init__(self, customName=random.Random().random()):
        self.id = customName
    pass