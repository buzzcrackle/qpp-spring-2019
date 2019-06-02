import busio
import board
import adafruit_rfm69
import requests
import time
from digitalio import DigitalInOut, Direction, Pull

url = "http://35.231.1.207:3000/"

# RFM69 Configuration
'''packet = None
CS = DigitalInOut(board.CE1)
RESET = DigitalInOut(board.D25)
spi = busio.SPI(board.SCK, MOSI=board.MOSI, MISO=board.MISO)
rfm69 = adafruit_rfm69.RFM69(spi, CS, RESET, 433.0)
rfm69.encryption_key = None
'''
while True:
	packetTX = None
	packetRX = None
	r = requests.get(url + "bot-called")
	json = r.json()
	if (json["isCalled"]):
		r = requests.get(url + "bot-instructions")
		json = r.json()
		directions = ""
		dirArr = json["relativePath"]
		revArr = json["relativeReverse"]
		for x in dirArr:
			directions += str(x)
		directions += "-"
		for y in revArr:
			directions += str(y)
		packetTX = bytes(directions, "utf-8")
		'''while (packetRX == None):
			packetRX = rfm69.receive()
			r = requests.get(url + "bot-finished")
		rtm69.send(packetTX)'''
		print(directions)
	time.sleep(5)
