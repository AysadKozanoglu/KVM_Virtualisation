#!/bin/sh
# Author: Aysad Kozanoglu
#
# Quick Launch script
# wget -O part2.sh https://git.io/fpAJA && sh part2.sh

  PYTHONBIN=$(which python)
WEBVIRTPATH=/var/www/webvirtmgr

cd /var/www

git clone git://github.com/retspen/webvirtmgr.git

cd $WEBVIRTPATH

pip install -r requirements.txt 

# syncdb - set first user for webvirt
# yes
# /var/www/webvirtmgr/manage.py syncdb

# add more users: 
# set your username / password for webvirtMgr
# /var/www/webvirtmgr/manage.py createsuperuser

# initial collection
# yes
# /var/www/webvirtmgr/manage.py collectstatic

chown -R www-data:www-data ${WEBVIRTPATH}

rm /etc/nginx/sites-enabled/default

# get webvirtmgr nginx config port 80
wget -O /etc/nginx/conf.d/webvirt.conf "https://git.io/fpNhE"; nginx -t && nginx -s reload

## skipping supervisor part
#
# service supervisor stop
## get supervisor config file
# wget -O /etc/supervisor/conf.d/webvirtmgr.conf "https://git.io/fpNhi"
# service supervisor start
# service supervisor status
# killall python ; killall /usr/bin/python
##


# ubuntu
#usermod -a -G libvirtd www-data && id www-data
# debian
#usermod -a -G libvirt www-data && id www-data

cat /etc/group | grep libvirtd > /dev/null && usermod -a -G libvirtd www-data && id www-data || usermod -a -G libvirt www-data && id www-data

# WEBVIRTPATH=/var/www/webvirtmgr
# run as user www-data 
#sudo  -u www-data bash -c "$PYTHONBIN ${WEBVIRTPATH}/console/webvirtmgr-console >> ${WEBVIRTPATH}/webvirtmgrService.log 2>&1 &" 

# run as user www-data 
#sudo  -u www-data bash -c "$PYTHONBIN ${WEBVIRTPATH}/manage.py runserver 127.0.0.1:8000 >> ${WEBVIRTPATH}/webvirtmgrService.log 2>&1 & "  

# download iso image debian stretch  for  webgui selection (storage > ISO)
wget -qO ${WEBVIRTPATH}/images/debian-9.6.0-amd64-netinst.iso https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.6.0-amd64-netinst.iso

echo "=========================================="
echo "finished. open your ip or fqdn on browser"
echo "=========================================="

# end of installation 
# open in browser your ip or fpdn(if server_name configured in nginx conf)
