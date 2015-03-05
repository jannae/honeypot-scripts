
# Python and System pre-reqs
sudo apt-get install -y nodejs git unzip python-setuptools python-dev python-pip python-netaddr

# # Manual Node v0.10.33 install if needed
# sudo wget http://nodejs.org/dist/v0.10.33/node-v0.10.33.tar.gz
# sudo tar xzvf node-v0.10.33.tar.gz
# cd node-v0.10.33
# sudo ./configure
# sudo make
# sudo make install

sudo ln -s /usr/bin/nodejs /usr/bin/node

# node things
sudo npm install -g less

# Django v1.4.5
sudo pip -v install django==1.4.5

# prerequisites using pip for automated installation
sudo pip install pygeoip django-pagination django-tables2 django-compressor django-htmlmin django-filter

cd /opt/

# django-tables2-simplefilter
sudo pip install -e git://github.com/benjiec/django-tables2-simplefilter.git#egg=django_tables2_simplefilter

# pynetsubtree
sudo git clone https://github.com/bro/pysubnettree.git
cd /opt/pysubnettree/
sudo python setup.py install

cd /opt/

sudo git clone https://github.com/rubenespadas/DionaeaFR.git

sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
sudo wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz

sudo gunzip GeoLiteCity.dat.gz
sudo gunzip GeoIP.dat.gz

sudo mv GeoIP.dat DionaeaFR/DionaeaFR/static
sudo mv GeoLiteCity.dat DionaeaFR/DionaeaFR/static

cd /opt/DionaeaFR/

#### TOTAL HACK HERE ####
sudo mkdir /var/run/dionaeafr/
sudo touch /var/run/dionaeafr/dionaeafr.pid

sudo python manage.py collectstatic
sudo python manage.py runserver 0.0.0.0:8000

