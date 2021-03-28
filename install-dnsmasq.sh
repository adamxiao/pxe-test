#!/usr/bin/env bash

# TODO: 定制修改
# 1. 修改dhcp网段
# 2. 修改tftp服务器相关配置

set -e

yum install -y dnsmasq
systemctl enable dnsmasq

cat > /etc/dnsmasq.d/pxe-dhcp.conf << EOF
interface=eth1
bind-interfaces

dhcp-range=192.168.56.100,192.168.56.200,255.255.255.0,1h
dhcp-option=3,192.168.56.1
dhcp-option=6,114.114.114.114

dhcp-match=set:efi-x86_64,option:client-arch,7
dhcp-match=set:efi-x86_64,option:client-arch,9
dhcp-match=set:efi-x86,option:client-arch,6
dhcp-match=set:efi-arm,option:client-arch,11
dhcp-match=set:bios,option:client-arch,0
dhcp-boot=tag:efi-x86_64,shim.efi,,10.20.1.100
dhcp-boot=tag:efi-x86,shim.efi,,10.20.1.100
dhcp-boot=tag:efi-arm,arm/shim.efi,,10.20.1.100
dhcp-boot=tag:bios,pxelinux/pxelinux.0,,10.20.1.100

EOF

# 检查dhcp服务是否正常起来
systemctl start dnsmasq
netstat -anup | grep dnsmasq && echo "install and start dnsmasq success"
