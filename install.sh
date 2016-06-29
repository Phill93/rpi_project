#!/bin/bash

BASEDIR=$(dirname "$0")

apt-get install apache2 mysql-server php5-mysql php5 libapache2-mod-php5 php5-mcrypt -y
apt-get install python3 python3-pip -y
pip3 install pymysql
cp tools/weather.cnf /etc/mysql/conf.d/
systemctl restart mysql
mysql -p < tools/weather.sql
echo "*/1 * * * * root python3 ${BASEDIR}/tools/read_sensor.py" > /etc/cron.d/weather
ln -s ${BASEDIR} /var/www/html/weather
