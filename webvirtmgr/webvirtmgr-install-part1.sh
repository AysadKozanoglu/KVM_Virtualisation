#!/bin/sh
# Author: Aysad Kozanoglu
#
# Quick Launch Script:
# wget -O - https://git.io/fpAJH | sh

askReboot() {
while true; do
    read -p "Do you wish to reboot server?" yn
    case $yn in
        [Yy]* ) echo "OK, server will boot in 5 sec..."; sleep 4; shutdown -r now; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y for yes or n for no.";;
    esac
done
}

# set locale en_EN
wget -O - https://git.io/fpbwk | sh

bash -x /etc/bash.bashrc

apt update

# install KVM HOST libvirt  server headless 
wget -O - https://git.io/fpAfx | sudo sh

# needed packages for webvirtmgr
apt-get install git python-pip python-libvirt python-libxml2 novnc supervisor nginx -y --yes

clear
printf "\033c"
# ask to reboot server 
askReboot
# next step part 2
