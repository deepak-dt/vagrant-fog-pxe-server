#!/usr/bin/env bash

export WORKSPACE=$PWD
export GIT_EMAIL=$1
export GIT_USERNAME=$2
export GIT_PASSWORD=$3
export DEVSTACK_BRANCH="stable/newton"
export phy_intf="enp0s4"

echo "******************************************************"
echo "Contrail-installer : Configure SSH keys for github"
echo "******************************************************"

echo "*************************************************"
echo "Contrail-installer : Installing the required Packages"
echo "*************************************************"
# Steps to install and configure devstack
sudo apt-get update 
sudo apt-get -y install git vim-gtk libpq-dev python-pip 
#sudo pip install git-review tox 

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME
git config --global user.editor "vim"

echo "******************************************************************************"
echo "Contrail-installer : Checkout contrail-installer and devstack repositories"
echo "******************************************************************************"



