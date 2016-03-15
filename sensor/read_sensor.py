#!/usr/bin/python3

import time
import pymysql.cursors

debug = False

connection = pymysql.connect(
    host='localhost',
    user='web',
    password='r4spi',
    db='rpi_project',
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor)

sensor_path = "/sys/bus/iio/devices/iio:device0/"

temp_file = sensor_path + "in_temp_input"
hum_file = sensor_path + "in_humidityrelative_input"

temp_data = open(temp_file)
hum_data = open(hum_file)

temp = None
hum = None

while not temp:
    try:
        temp = temp_data.read()
    except OSError:
        time.sleep(1)

temp = float(temp)

temp /= 1000
if debug == True:
    print(temp)

while not hum:
    try:
        hum = hum_data.read()
    except OSError:
        hum.sleep(1)

hum = float(hum)
hum /= 1000
if debug == True:
    print(hum)

try:
    with connection.cursor() as cursor:
        sql = "INSERT INTO data(temp, hum) VALUES (%s, %s)"
        cursor.execute(sql, (temp, hum))
    connection.commit()
finally:
    connection.close()
