#!/usr/bin/python3

#Переходник USB-RS232 при подключении в Linux создаёт виртуальный порт ttyUSB0
#Для настройки доступа к порту /dev/ttyUSB0 необходимо добавить пользователя в группу dialout:
#sudo usermod -aG dialout $USER
#Может понадобится команда
#sudo chmod 777 -R /dev/ttyUSB0
#Открывать терминал можно только после подключения переходника USB-RS232, чтобы был виден порт

import serial

port = "/dev/ttyUSB0" #имя порта, в Windows это может быть COM1
baudrate = 9600 #бод
#message = b'Hello, World!' #Передаваемое сообщение в бинарном формате
message = bytearray(chr(0b00111010), "utf-8") #Передаём ASCII символ в бинарном формате

print ("Opening %s" % port)
ser = serial.Serial(port, baudrate = baudrate, parity = 'N', timeout = 2, bytesize=8, stopbits=1, rtscts=False, xonxoff=False)

print("Sending %s" %message)
ser.write(message)

if ser.is_open:
    ser.close()
    print("Serial connection closed.")
