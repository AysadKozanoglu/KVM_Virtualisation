#!/bin/sh
# Author: Aysad Kozanoglu
#
# Quick Launch Script:
# wget -O - https://git.io/fpAJH | sh


# set locale en_EN
wget -O - https://git.io/fpbwk | sh

bash -x /etc/bash.bashrc

apt update

# install KVM HOST libvirt  server headless 
wget -O - https://git.io/fpAfx | sudo sh

# needed packages for webvirtmgr
apt-get install git python-pip python-libvirt python-libxml2 novnc supervisor nginx -y --yes

# ask to reboot server 
wget -qO reboot.sh https://git.io/fpNpo && chmod a+x reboot.sh ; sh reboot.sh

# next step part 2
