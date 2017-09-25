#!/usr/bin/env bash
# Ref: https://askubuntu.com/questions/412574/pxe-boot-server-installation-steps-in-ubuntu-server-vm/414813

export WORKSPACE=$PWD
export phy_intf="enp0s8"
export dhcp_server_ip="203.0.113.127"
export dhcp_subnet="203.0.113.0"
export dhcp_netmask="255.255.255.0"
export dhcp_range="203.0.113.189 203.0.113.198"
export dhcp_broadcast_addr="203.0.113.255"

line_to_rep_orig_1="INTERFACES=\"\""
line_to_rep_new_1="INTERFACES=\""$phy_intf"\""

line_to_search_1="#  max-lease-time 7200;"
line_to_add_1="subnet "$dhcp_subnet" netmask "$dhcp_netmask" {\n    range "$dhcp_range";\n    option subnet-mask "$dhcp_netmask";\n    option routers "$dhcp_server_ip";\n    option broadcast-address "$dhcp_broadcast_addr";\n    filename \"pxelinux.0\";\n    next-server "$dhcp_server_ip";\n}"

line_to_search_2="#       run this only on machines acting as \"boot servers.\""
line_to_add_2="tftp    dgram   udp wait    root    \/usr\/sbin\/in.tftpd  \/usr\/sbin\/in.tftpd -s \/var\/lib\/tftpboot"

line_to_search_3="default install"

# Boot from ISO
# line_to_add_3="default Ubuntu-Xenial-ISO\nlabel Ubuntu-Xenial-ISO\n        menu label ^Boot Ubuntu-16.06-Xenial ISO\n        menu default\n        text help\n    Boot from the Ubuntu-16.06-Xenial ISO.\n        endtext\n        kernel memdisk\n        append vga=788 initrd=ubuntu-16.04.3-server-amd64.iso --- quiet\n"

# Boot from NFS
#line_to_add_3="default Ubuntu-Xenial-ISO\nlabel Ubuntu-Xenial-ISO\n        menu label ^Boot Ubuntu-16.06-Xenial ISO\n        menu default\n        text help\n    Boot from the Ubuntu-16.06-Xenial ISO.\n        endtext\n        kernel iso/ubuntu/ubuntu-16.04-server-amd64/install/vmlinuz \n        append vga=788 root=/dev/nfs boot=casper netboot=nfs nfsroot="$dhcp_server_ip":/var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64 initrd=iso/ubuntu/ubuntu-16.04-server-amd64/install/initrd.gz quiet splash --\n"

# Boot from netboot
line_to_add_3="default Ubuntu-Xenial-ISO\nlabel Ubuntu-Xenial-ISO\n        menu label ^Boot Ubuntu-16.04-Xenial ISO\n        menu default\n        text help\n    Boot from the Ubuntu-16.04-Xenial ISO.\n        endtext\n        kernel ubuntu-installer/amd64/linux \n        append vga=788 initrd=ubuntu-installer/amd64/initrd.gz --- quiet\n"

line_to_rep_orig_2="default install"
line_to_rep_new_2="default Ubuntu-Xenial-ISO"

echo "*************************************************"
echo "Pxe-installer : Installing the required Packages"
echo "*************************************************"
# Ref: https://askubuntu.com/questions/412574/pxe-boot-server-installation-steps-in-ubuntu-server-vm/414813
sudo apt-get update 
sudo apt-get -y install isc-dhcp-server openbsd-inetd lftp tftpd-hpa syslinux apache2
#sudo apt-get -y install nfs-kernel-server nfs-common

echo "******************************************************************************"
echo "Pxe-installer : DHCP Setup"
echo "******************************************************************************"
# Ref: https://askubuntu.com/questions/412574/pxe-boot-server-installation-steps-in-ubuntu-server-vm/414813

sed -n "1h;2,\$H;\${g;s/$line_to_rep_orig_1/$line_to_rep_new_1/;p}" /etc/default/isc-dhcp-server > $WORKSPACE/isc-dhcp-server
sudo mv $WORKSPACE/isc-dhcp-server /etc/default/isc-dhcp-server
sudo sed -i "/$line_to_search_1/a$line_to_add_1" /etc/dhcp/dhcpd.conf
sudo service isc-dhcp-server restart

echo "******************************************************************************"
echo "Pxe-installer : TFTP Setup"
echo "******************************************************************************"
# Ref: https://askubuntu.com/questions/412574/pxe-boot-server-installation-steps-in-ubuntu-server-vm/414813

sudo sed -i "/$line_to_search_2/a$line_to_add_2" /etc/inetd.conf
sudo update-inetd --enable BOOT
sudo service openbsd-inetd restart
sudo service tftpd-hpa restart

echo "******************************************************************************"
echo "Pxe-installer : PXE boot files setup"
echo "******************************************************************************"
#cd /var/lib/tftpboot/
#sudo wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz
#sudo tar -xvzf netboot.tar.gz -C /var/lib/tftpboot/
#sudo chown -R nobody:nogroup /var/lib/tftpboot

echo "******************************************************************************"
echo "Pxe-installer : PXE boot files setup - ISO"
echo "******************************************************************************"
cd /var/lib/tftpboot/
#sudo mkdir ubuntu-iso-installer/
#sudo mkdir ubuntu-iso-installer/amd64
#sudo mkdir ubuntu-iso-installer/amd64/boot-screens

#sudo cp /usr/lib/syslinux/memdisk /var/lib/tftpboot/

# Create the mount point
#sudo mkdir -p /var/lib/tftpboot/iso/
#sudo mkdir -p /var/lib/tftpboot/iso/ubuntu/
#sudo mkdir -p /var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64

#sudo echo "/var/lib/tftpboot/iso/ubuntu-16.04.3-server-amd64.iso /var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64 udf,iso9660 user,loop 0 0" >> /etc/fstab
#sudo mount -a
#sudo ls -lash /var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64

# Create NFS share
#sudo echo "/var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64 *(ro,sync,no_wdelay,insecure_locks,no_root_squash,insecure)" >> /etc/exports
#sudo /etc/init.d/nfs-kernel-server restart

# kernel iso/ubuntu/ubuntu-16.04-server-amd64/install/vmlinuz
# append vga=788 root=/dev/nfs boot=install netboot=nfs nfsroot=203.0.113.127:/var/lib/tftpboot/iso/ubuntu/ubuntu-16.04-server-amd64 initrd=iso/ubuntu/ubuntu-16.04-server-amd64/install/initrd.gz quiet splash --


# NSF not working - Go the Apache way
sudo mkdir -p /var/lib/tftpboot/iso/
sudo mkdir -p /var/www/html/ubuntu
sudo mkdir -p /var/www/html/ubuntu/ubuntu-16.04-server-amd64

# Get the ISO
#sudo wget http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso /var/lib/tftpboot/iso/
sudo mv /home/vagrant/ubuntu-16.04.3-server-amd64.iso /var/lib/tftpboot/iso/

# Create the mount point
sudo su -c "echo -e '/var/lib/tftpboot/iso/ubuntu-16.04.3-server-amd64.iso /var/www/html/ubuntu/ubuntu-16.04-server-amd64 udf,iso9660 user,loop 0 0' >> /etc/fstab"
sudo mount -a
sudo ls -lash /var/www/html/ubuntu/ubuntu-16.04-server-amd64
#cp -r /media/cdrom/* /var/www/ubuntu/
sudo service apache2 restart

# Add menu option for ISO
sudo cp -r /var/www/html/ubuntu/ubuntu-16.04-server-amd64/install/netboot/* /var/lib/tftpboot/
sudo chown -R nobody:nogroup /var/lib/tftpboot

sudo sed -i "/$line_to_search_3/a$line_to_add_3" /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/txt.cfg 
sudo sed -n "1h;2,\$H;\${g;s/$line_to_rep_orig_2/$line_to_rep_new_2/;p}" /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/txt.cfg > /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/txt.cfg.new
sudo mv /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/txt.cfg.new /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/txt.cfg 
  
