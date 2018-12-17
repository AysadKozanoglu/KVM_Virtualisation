#!/bin/sh
# Author: Aysad Kozanoglu

cd /var/www

git clone git://github.com/retspen/webvirtmgr.git

cd /var/www/webvirtmgr

pip install -r requirements.txt 

# set your username / password for webvirtMgr
# yes
/var/www/webvirtmgr/manage.py syncdb

# initial collection
# yes
/var/www/webvirtmgr/manage.py collectstatic

chown -R www-data:www-data /var/www/webvirtmgr

rm /etc/nginx/sites-enabled/default

# get webvirtmgr nginx config port 80
wget -O /etc/nginx/conf.d/webvirt.conf "https://git.io/fpNhE"; nginx -t && nginx -s reload

service supervisor stop

# get supervisor config file
wget -O /etc/supervisor/conf.d/webvirtmgr.conf "https://git.io/fpNhi"

service supervisor start

service supervisor status

killall python ; killall /usr/bin/python

usermod -a -G libvirtd www-data && id www-data

# run as user www-data 
sudo  -u www-data bash -c "/usr/bin/python /var/www/webvirtmgr/console/webvirtmgr-console >> /var/www/webvirtmgr/webvirtmgrService.log 2>&1 &" 

# run as user www-data 
sudo  -u www-data bash -c "/usr/bin/python /var/www/webvirtmgr/manage.py runserver 127.0.0.1:8000 >> /var/www/webvirtmgr/webvirtmgrService.log 2>&1 & "  

# download iso image debian stretch  for  webgui selection (storage > ISO)
wget -qO /var/www/webvirtmgr/images/debian-9.6.0-amd64-netinst.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.6.0-amd64-netinst.iso

# end of installation open in browser your ip or fpdn(if server_name configured in nginx conf)
