#!/usr/bin/env bash

export WORKSPACE=$PWD
export phy_intf="enp0s8"

echo "*************************************************"
echo "Pxe-installer : Installing the required Packages"
echo "*************************************************"
# Steps to install and configure devstack
sudo apt-get update 
sudo apt-get -y install git vim-gtk libpq-dev python-pip 

echo "******************************************************************************"
echo "Pxe-installer : fetch and setup the FOG"
echo "******************************************************************************"
sudo mkdir -p /opt/fog-setup
cd /opt/fog-setup

sudo wget https://sourceforge.net/projects/freeghost/files/latest/download?source=files
sudo mv download?source=files fog_1.4.4.tar.gz
sudo tar -xvzf fog*
cd fog*
cd bin
sudo ./installfog.sh


# For PXE-client
# wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz

