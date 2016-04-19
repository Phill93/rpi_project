#!/usr/bin/python3

import time
import pymysql.cursors

debug = False


def readtemp(temp_file, check):
    temp_data = open(temp_file)
    temperature = None
    while not temperature:
        try:
            temperature = temp_data.read()
            temperature = float(temperature)
            temperature /= 1000
            if temperature >= check['min'] or temperature <= check['max']:
                return temperature
            else:
                temperature = None
        except OSError:
            time.sleep(1)


def readhum(hum_file, check):
    hum_data = open(hum_file)
    humidity = None
    while not humidity:
        try:
            humidity = hum_data.read()
            humidity = float(humidity)
            humidity /= 1000
            if humidity >= check['min'] or humidity <= check['max']:
                return humidity
            else:
                humidity = None
        except OSError:
            hum.sleep(1)


def writedatabase(credentials, db_temp, db_hum):
    connection = pymysql.connect(
        host=credentials["host"],
        user=credentials["user"],
        password=credentials["password"],
        db=credentials["db"],
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor)
    try:
        with connection.cursor() as cursor:
            sql = "INSERT INTO hums(humidity) VALUES (%s)"
            cursor.execute(sql, db_hum)
            sql2 = "INSERT INTO temps(temperature) VALUES (%s)"
            cursor.execute(sql2, db_temp)
        connection.commit()
    finally:
        connection.close()


sensor_path = "/sys/bus/iio/devices/iio:device0/"

temperature_file = sensor_path + "in_temp_input"
humidity_file = sensor_path + "in_humidityrelative_input"

check_temp = {"min": -40.0, "max": 80.0}
check_hum = {"min": 0.0, "max": 100.0}
database = {
    "host": "localhost",
    "user": "web",
    "password": "web",
    "db": "rpi_project"
}

temp = readtemp(temperature_file, check_temp)
hum = readhum(humidity_file, check_hum)

if debug:
    print("Temp: " + temp)
    print("Hum: " + hum)

writedatabase(database, temp, hum)
