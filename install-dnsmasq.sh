#!/usr/bin/env bash

set -e

yum install -y dnsmasq
systemctl enable dnsmasq

cat > /etc/dnsmasq.d/pxe-dhcp.conf << EOF
dhcp-range=eth0,192.168.56.100,192.168.56.200,255.255.255.0,1h
dhcp-option=3,192.168.56.1
dhcp-option=6,114.114.114.114
dhcp-option=6,8.8.8.8

dhcp-boot=pxelinux/pxelinux.0,pxeserver,192.168.56.2
EOF

# 检查dhcp服务是否正常起来
systemctl start dnsmasq
netstat -anup | grep dnsmasq && echo "install and start dnsmasq success"
