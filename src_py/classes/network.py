
# direct
import socket
import json
import _thread
import time
import struct

# class
class Network:
    
    # __init__ variables (also public)
    access_key = ""
    ip = ""
    ports = []
    
    # privates
    __sockets = []
    __threads = []
    __data_queue = []
    __has_setup = False
    
    # Override this for custom behavior.
    def getReturnData(self, addr, receieved_data):
        return json.dumps({"Result": "Accepted"})

    # Override this for custom behavior.
    def handleReceivedData(self, receieved_data):
        print("Recieved:", receieved_data)

    # On Incoming Data, check validility.
    def __onDataRecieve(self, address, data):
        returnData = json.dumps({"Result": "Denied"})
        if type(data) == dict:
            if 'ACCESS_KEY' in data.keys() and str(data['ACCESS_KEY']) == self.access_key:
                print('valid')
                self.handleReceivedData(data)
                returnData = self.getReturnData(address, data)
        return returnData
    
    # Setup socket handling
    def __setup_network_handle(self):
        while True:
            for sock in self.__sockets:
                conn, addr = sock.accept()
                data = conn.recv(50000)
                my_json = data.decode('utf-8')
                try:
                    data = json.loads(my_json[my_json.find("{"):])
                except:
                    data = None
                returnData = self.__onDataRecieve(addr, data)
                conn.sendall(str.encode(str(returnData)))
                conn.close()
    
    # Setup the connection(s)
    def __setup(self):
        if self.__has_setup:
            return
        self.__has_setup = True
        # initialise each socket
        for portNumber in self.ports:
            print(self.ip + ":" + str(portNumber))
            newSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            newSocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            newSocket.bind((self.ip, portNumber))
            #newSocket.setblocking(0)
            newSocket.listen(1)
            self.__sockets.append(newSocket)
        # create a thread for handling the sockets
        self.__threads.append(_thread.start_new_thread(self.__setup_network_handle, ())) 
        print("Total of " + str(len(self.ports)) + " ports opened.")
       
    # Kill connection
    def kill(self):
        for thread in self.__threads:
            thread.exit()
        for sock in self.__sockets:
            sock.shutdown(socket.SHUT_RDWR)
    
    def __init__(self, ports=[1337], ip="127.0.0.1", access_key="123123123"):
        self.ip = ip
        self.ports = ports
        self.access_key = str(access_key)
        self.__setup()
    
    pass