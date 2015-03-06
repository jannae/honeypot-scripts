#!/bin/bash
#
# Setting up the DionaeaFR Visualization interface
#

echo '[apt-get] Getting up to date...'
sudo apt-get update && sudo apt-get upgrade -y &> /dev/null

# Python and System pre-reqs
echo '[apt-get] Installing nodejs npm git unzip python-setuptools python-dev python-pip python-netaddr'
sudo apt-get install -y nodejs npm git unzip python-setuptools python-dev python-pip python-netaddr &> /dev/null

# # Manual Node v0.10.33 install if needed
# sudo wget http://nodejs.org/dist/v0.10.33/node-v0.10.33.tar.gz
# sudo tar xzvf node-v0.10.33.tar.gz
# cd node-v0.10.33
# sudo ./configure
# sudo make
# sudo make install

echo '[symlink] /usr/bin/nodejs <-> /usr/bin/node'
sudo ln -s /usr/bin/nodejs /usr/bin/node

# node things
echo '[npm] Installing less'
sudo npm install -g less &> /dev/null

# Django v1.4.5
echo '[pip] Installing django v1.4.5'
sudo pip -v install django==1.4.5

echo '[pip] Installing pygeoip django-pagination django-tables2 django-compressor django-htmlmin django-filter'
# prerequisites using pip for automated installation
sudo pip install pygeoip django-pagination django-tables2 django-compressor django-htmlmin django-filter &> /dev/null

# django-tables2-simplefilter
echo '[pip] Installing django-tables2-simplefilter'
sudo pip install -e git://github.com/benjiec/django-tables2-simplefilter.git#egg=django_tables2_simplefilter

cd /opt/

# pynetsubtree
echo '[python] Instaling pysubnettree'
sudo git clone https://github.com/bro/pysubnettree.git
sudo python /opt/pysubnettree/setup.py install

echo '[git] Downloading DionaeaFR'
sudo git clone https://github.com/rubenespadas/DionaeaFR.git

echo '[sed] Edit settings.py'
sudo sed 's|/var/lib/dionaea/|/var/dionaea/|g' /opt/DionaeaFR/DionaeaFR/settings.py.dist > /opt/DionaeaFR/DionaeaFR/settings.py

echo '[wget] GeoLiteCity.dat, GeoIP.dat'
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz

sudo gunzip GeoLiteCity.dat.gz
sudo gunzip GeoIP.dat.gz

sudo mv GeoIP.dat DionaeaFR/DionaeaFR/static
sudo mv GeoLiteCity.dat DionaeaFR/DionaeaFR/static

echo 'Hacking the pid problem...'
#### TOTAL HACK HERE ####
sudo mkdir /var/run/dionaeafr/
sudo touch /var/run/dionaeafr/dionaeafr.pid

echo 'Starting up...'
cd /opt/DionaeaFR/
sudo python manage.py collectstatic
sudo python manage.py runserver 0.0.0.0:8000
