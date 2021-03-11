#!/usr/bin/env bash

# 基于centos7构建(或kylin341?)
# dhcp + tftp服务 + 一个测试的http

# keyword "pxe install centos"
# refer https://www.tecmint.com/install-pxe-network-boot-server-in-centos-7/

yum install -y dnsmasq dhcpd syslinux tftp-server
systemctl enable dnsmasq tftp
tftp_dir=/var/lib/tftpboot

# dhcp 配置 TODO: 需要自己修改
cat > /etc/dnsmasq.d/pxe-dhcp.conf << EOF
interface=eth0
bind-interfaces
domain=template-centos

dhcp-range=eth0,192.168.56.230,192.168.56.253,255.255.255.0,1h
dhcp-option=3,192.168.56.1
dhcp-option=6,192.168.56.1
dhcp-option=6,8.8.8.8
server=8.8.4.4
dhcp-option=28,10.0.0.255
dhcp-option=42,0.0.0.0

dhcp-boot=pxelinux/pxelinux.0,pxeserver,192.168.56.1

pxe-prompt="Press F8 for menu.", 2
pxe-service=x86PC, "Install CentOS from network server", pxelinux
EOF

# 构建tftp目录结构
cp /usr/share/syslinux/{menu.c32,pxelinux.0} ${tftp_dir}
mkdir ${tftp_dir}/pxelinux.cfg
cat > ${tftp_dir}/pxelinux.cfg/default << EOF
default menu.c32
timeout 300
menu title kylin

menu title ########## PXE Boot Menu ##########

label local
  menu default
  menu label Boot from ^local drive
  localboot 0xffff

label -ksvd-818
  menu label ^Install KSVD-818 x64
  kernel image/ksvd818/vmlinuz
  append initrd=image/ksvd818/initrd.img method=http://192.168.56.2/ksvd818 ks=http://192.168.56.2/ksvd818/kickstart/ks.cfg devfs=nomount inst.vnc inst.vncpassword=ksvd2020
EOF

# TODO: 作为nat网关配置
# iptables -t nat -I POSTROUTING -o Mdvs -j MASQUERADE
# sysctl -w net.ipv4.ip_forward=1

# TODO: /var/www/html
# 构建软件仓库源
# createrepo -d -g comps.xml .
