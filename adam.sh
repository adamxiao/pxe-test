#!/bin/bash

set -e

# root权限安装
sudo yum install -y httpd createrepo tftp-server xinetd syslinux dhcp vsftpd
systemctl enable httpd xinetd dhcpd httpd vsftpd tftp

centos_dir=/var/www/html/centos
mkdir -p $centos_dir
#umount /dev/sr0
mount /dev/sr0 $centos_dir
# cp -a /mnt/* $centos_dir

# XXX: kick start
# cat > $centos_dir/centos.cfg

sed -i -c -e '/disable/s/\<yes\>/no/' /etc/xinetd.d/tftp

# tftp config
mkdir -p /var/lib/tftpboot/pxelinux
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/pxelinux
cp $centos_dir/isolinux/* /var/lib/tftpboot/pxelinux
cp $centos_dir/images/pxeboot/{vmlinuz,initrd.img} /var/lib/tftpboot/pxelinux/
mkdir -p /var/lib/tftpboot/pxelinux/pxelinux.cfg
cp $centos_dir/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux/pxelinux.cfg/default
# cat > /var/lib/tftpboot/pxelinux/pxelinux.cfg/default << EOF
# EOF
cat > /root/pxe-default << EOF
label ks
  menu label ^Auto Install CentOS 7
  kernel vmlinuz
  append initrd=initrd.img ip=dhcp inst.repo=http://192.168.56.2/centos/ net.ifnames=0 biosdevname=0
EOF

# config dhcp config
# cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf
cat > /etc/dhcp/dhcpd.conf << EOF
# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#

# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# Use this to enble / disable dynamic dns updates globally.
#ddns-update-style none;

# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
#authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

subnet 192.168.56.0 netmask 255.255.255.0 {
     range dynamic-bootp 192.168.56.100 192.168.56.200;
     option subnet-mask              255.255.255.0;  #设置子网掩码
     option routers                  192.168.56.2;    #设置网关
     next-server                     192.168.56.2;   #设置TFTP-Server地址
     filename                        "pxelinux/pxelinux.0";   #设置TFTP需要下载的文件
}
EOF

cp /etc/sysconfig/network-scripts/ifcfg-eth0 /root/ifcft-eth0.dhcp
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
BOOTPROTO=static
DEVICE=eth0
ONBOOT=yes
STARTMODE=auto
TYPE=Ethernet
USERCTL=no
IPADDR=192.168.56.2
PREFIX=24
GATEWAY=192.168.56.1
DNS1=114.114.114.114
EOF

systemctl restart network
systemctl restart httpd xinetd dhcpd httpd vsftpd tftp

systemctl disable firewalld
systemctl stop firewalld
