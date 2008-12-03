import threading

class ThreadCreation ( threading.Thread ):
    
    def run ( self ):
        i = 0
        i = i + 1

for i in range (0, 10000):
   ThreadCreation().start()
