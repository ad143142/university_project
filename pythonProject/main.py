import serial

ser = serial.Serial('COM5', 38400)  # Replace 'COM3' with your Arduino's serial port

while True:
    if ser.in_waiting > 0:
        data = ser.read(11)  # Read 5 bytes (size of your byte array)
        print("Received:", data)
