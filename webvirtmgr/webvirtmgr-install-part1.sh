#!/bin/sh
# Author: Aysad Kozanoglu
#
# Quick Launch Script:
# wget -O part1.sh https://git.io/fpAJH && sh part1.sh

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

showLabel() {
clear;
echo "=================================================="
echo "KVM CLoud Virtualisation - Auto installer script"
echo "author: Aysad Kozanoglu"
echo "this installer is for:"
echo "+ Ubuntu 16.04"
echo "+ Ubuntu 18.04"
echo "+ Debian 8 Jessie"
echo "+ Debuan 9 stretch "
echo "Your System is:"

lsb_release -a

echo   "Enter to begin or ctrl+c to break"
read -s -n 1 key
}

showLabel


# set locale en_EN
wget -O - https://git.io/fpbwk | sh

bash -x /etc/bash.bashrc

apt update

# install KVM HOST libvirt  server headless 
wget -O - https://git.io/fpAfx | sudo sh

# needed packages for webvirtmgr
apt-get install git python-pip python-libvirt python-libxml2 novnc supervisor nginx qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools libosinfo-bin -y --yes


clear
printf "\033c"
# ask to reboot server 
askReboot
# next step part 2
