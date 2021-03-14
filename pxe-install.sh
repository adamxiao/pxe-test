#!/usr/bin/env bash

set -e

# TODO: 定制修改
# 1. dhcp网段修改
# 2. tftp镜像配置
# 3. http安装源配置

# 基于centos7构建(或kylin341?)
# dhcp + tftp + http

# keyword "pxe install centos"
# refer https://www.tecmint.com/install-pxe-network-boot-server-in-centos-7/

yum install -y dnsmasq syslinux httpd createrepo
systemctl enable dnsmasq httpd
tftp_dir=/var/lib/tftpboot

mkdir -p $tftp_dir
chown nobody:nobody $tftp_dir

cat > /etc/dnsmasq.d/pxe-dhcp.conf << EOF
interface=eth1
bind-interfaces

dhcp-range=192.168.56.230,192.168.56.253,255.255.255.0,1h
dhcp-option=3,192.168.56.1
dhcp-option=6,8.8.8.8

pxe-service=x86PC, "network installer", pxelinux

enable-tftp
tftp-root=/var/lib/tftpboot
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
