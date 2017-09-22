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
echo "Check for existing ssh keys...."
keys_count=$(ls -al ~/.ssh | grep id_rsa | wc -l)
if [ $keys_count = 0 ]
then
    echo "No existing ssh keys found....Generating a new ssh key...."
    ssh-keygen -t rsa -b 4096 -f $WORKSPACE/.ssh/id_rsa -N "" -P "" -C $GIT_EMAIL
else
    echo "Existing ssh key found....Reusing..."
fi

eval $(ssh-agent -s)
ssh-add $WORKSPACE/.ssh/id_rsa

echo "Registering SSH-key to github:"
#cat $WORKSPACE/.ssh/id_rsa.pub

curl -u "$GIT_USERNAME:$GIT_PASSWORD" \
    --data "{\"title\":\"VagrantContrailDevstackVm_`date +%Y%m%d%H%M%S`\",\"key\":\"`cat $WORKSPACE/.ssh/id_rsa.pub`\"}" \
    https://api.github.com/user/keys


#read -p "Please add above ssh-key to your github account. Press y to continue or n to abort [y/n] : " yn
#case $yn in
#    [Nn]* ) echo "SSH key not registered to github account...Aborting...."; exit;;
#esac

ssh -T -o StrictHostKeyChecking=no git@github.com

echo "*************************************************"
echo "Contrail-installer : Installing the required Packages"
echo "*************************************************"
# Steps to install and configure devstack
sudo apt-get update 
sudo apt-get -y install git vim-gtk libxml2-dev libxslt1-dev libpq-dev python-pip libsqlite3-dev 
sudo apt-get -y build-dep python-mysqldb 
sudo pip install git-review tox 

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME
git config --global user.editor "vim"

echo "******************************************************************************"
echo "Contrail-installer : Checkout contrail-installer and devstack repositories"
echo "******************************************************************************"

git clone https://github.com/juniper/contrail-installer.git

sed -i "/PHYSICAL_INTERFACE.*/s/.*/PHYSICAL_INTERFACE=$phy_intf/" localrc
#sed -i "/$line_to_search_1/a$line_to_add_1" $WORKSPACE/contrail-installer/contrail.sh

# Workaround - package not available in Ubuntu
sed -n "1h;2,\$H;\${g;s/$line_to_rep_orig_7/$line_to_rep_new_7/;p}" $WORKSPACE/contrail-installer/contrail.sh > $WORKSPACE/contrail-installer/contrail_1.sh
mv $WORKSPACE/contrail-installer/contrail_1.sh $WORKSPACE/contrail-installer/contrail.sh

# Replace git.openstack.org with https://github.com/openstack in "GIT_BASE=${GIT_BASE:-git://git.openstack.org}"
str_to_rep_old="git\:\/\/git.openstack.org"
str_to_rep_new="https\:\/\/git.openstack.org"


