#!/usr/bin/python3

import time
import pymysql.cursors

debug = False


def read(file, check):
    data_file = open(file)
    data = None
    while not data:
        try:
            data = data_file.read()
            data = float(data)
            data /= 1000
            if data >= check['min'] or data <= check['max']:
                return data
            else:
                data = None
        except OSError:
            time.sleep(1)


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

temp = read(temperature_file, check_temp)
hum = read(humidity_file, check_hum)

if debug:
    print("Temp: " + temp)
    print("Hum: " + hum)

writedatabase(database, temp, hum)
