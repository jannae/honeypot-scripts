#!/bin/bash
repo_dir="honeypot-scripts"
script_dir="honeypot-scripts/setup-scripts"

# Get updated
echo '[apt-get] Getting up to date'
sudo apt-get update &> /dev/null
sudo apt-get upgrade -y &> /dev/null

echo 'Getting all the files arranged...'
sudo mkdir /etc/dionaea
sudo cp ~/$script_dir/templates/dionaea.conf.tmpl /etc/dionaea/dionaea.conf
echo '[copied] /etc/dionaea/dionaea.conf'
sudo cp ~/$script_dir/templates/kippo.cfg.tmpl /tmp/kippo.cfg
echo '[copied] /tmp/kippo.cfg'


if [ $(dpkg-query -W -f='${Status}' sudo 2>/dev/null | grep -c "ok installed") -eq 0 ]
then
  #sudo package is not currently installed on this box
  echo '[Error] Please install sudo before contniuing (apt-get install sudo)'
  exit 1
fi

current_user=$(whoami)

if [ $(sudo -n -l -U ${current_user} 2>&1 | egrep -c -i "not allowed to run sudo|unknown user") -eq 1 ]
then
   echo '[Error]: You need to run this script under an account that has access to sudo'
   exit 1
fi

echo '[apt-get] Installing python-pip gcc python-dev'
sudo apt-get -y install python-pip gcc python-dev &> /dev/null

# Move SSH server from Port 22 to Port 54321
echo '[sshd] Moving Port...'
sudo sed -i 's:Port 22:Port 54321:g' /etc/ssh/sshd_config
sudo service ssh reload


## install p0f ##
echo '[apt-get] Installing p0f'
sudo apt-get install -y p0f  &> /dev/null
sudo mkdir /var/p0f/

# dependency for add-apt-repository
echo '[apt-get] Installing python-software-properties'
sudo apt-get install -y python-software-properties &> /dev/null

## install dionaea ##

#add dionaea repo
sudo add-apt-repository -y ppa:honeynet/nightly
echo '[apt-get] Updating source list and installing dionaea-phibo'
{
sudo apt-get update
sudo apt-get install -y dionaea-phibo
} &> /dev/null

#make directories
sudo mkdir -p /var/lib/dionaea/wwwroot
sudo mkdir -p /var/lib/dionaea/binaries
sudo mkdir -p /var/lib/dionaea/log
sudo mkdir -p /var/lib/dionaea/bistreams
sudo chown -R nobody:nogroup /var/lib/dionaea/


## install kippo - we want the latest so we have to grab the source ##

#install kippo to /opt/kippo
echo '[apt-get] Installing subversion python-dev openssl python-openssl python-pyasn1 python-twisted iptables'
sudo apt-get install -y subversion python-dev openssl python-openssl python-pyasn1 python-twisted iptables &> /dev/null

#install kippo to /opt/kippo
sudo mkdir /opt/kippo/
sudo git clone https://github.com/micheloosterhof/kippo.git /opt/kippo/
sudo cp /tmp/kippo.cfg /opt/kippo/

#add kippo user that can't login
sudo useradd -r -s /bin/false kippo

#set up log dirs
sudo mkdir -p /var/kippo/dl
sudo mkdir -p /var/kippo/log/tty
sudo mkdir -p /var/run/kippo

#delete old dirs to prevent confusion
sudo rm -rf /opt/kippo/dl
sudo rm -rf /opt/kippo/log

#set up permissions
sudo chown -R kippo:kippo /opt/kippo/
sudo chown -R kippo:kippo /var/kippo/
sudo chown -R kippo:kippo /var/run/kippo/

#point port 22 at port 2222
#we should have -i $iface here but it was breaking things with virtual interfaces
sudo iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

#persist iptables config
sudo iptables-save | sudo tee -a /etc/iptables.up.rules

#setup iptables restore script
sudo echo '#!/bin/sh' | sudo tee /etc/network/if-up.d/iptablesload
sudo echo 'iptables-restore < /etc/iptables.rules' | sudo tee -a /etc/network/if-up.d/iptablesload
sudo echo 'exit 0' | sudo tee -a /etc/network/if-up.d/iptablesload
#enable restore script
sudo chmod +x /etc/network/if-up.d/iptablesload

#download init files and install them
sudo cp ~/$script_dir/templates/p0f.init.tmpl /etc/init.d/p0f
sudo cp ~/$script_dir/init/dionaea /etc/init.d/dionaea
sudo cp ~/$script_dir/init/kippo /etc/init.d/kippo

#install system services
sudo chmod +x /etc/init.d/p0f
sudo chmod +x /etc/init.d/dionaea
sudo chmod +x /etc/init.d/kippo

sudo update-rc.d p0f defaults
sudo update-rc.d dionaea defaults
sudo update-rc.d kippo defaults

#start the honeypot software
sudo /etc/init.d/p0f start
sudo /etc/init.d/dionaea start
sudo /etc/init.d/kippo start
