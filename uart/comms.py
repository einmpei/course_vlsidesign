#!/usr/bin/python3

import serial
import threading

port = "/dev/ttyS0"
baudrate = 9600
message = b'Hello, World!'

print ("Opening %s" % port)
ser = serial.Serial(port, baudrate = baudrate, parity = 'N', timeout = 2, bytesize=8, stopbits=1, rtscts=False, xonxoff=False)
    
for i in message:
    print("Sending %s" % i)
    ser.write(i)

if ser.is_open:
    ser.close()
    print("Serial connection closed.")
