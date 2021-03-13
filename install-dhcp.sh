#!/usr/bin/env bash

# TODO: 定制修改
# 1. 修改dhcp网段
# 2. 修改tftp服务器相关配置

set -e

yum install -y dhcp
systemctl enable dhcpd

cat > /etc/dhcp/dhcpd.conf << EOF
# 字段详解见 http://cn.linux.vbird.org/linux_server/0340dhcp_2.php
option domain-name-servers 114.114.114.114, 8.8.8.8;

default-lease-time 600;
max-lease-time 7200;

log-facility local7;

subnet 192.168.56.0 netmask 255.255.255.0 {
     range dynamic-bootp 192.168.56.100 192.168.56.200;
     option subnet-mask              255.255.255.0;  #设置子网掩码
     option routers                  192.168.56.1;   #设置网关
     next-server                     10.20.1.100;    #设置TFTP-Server地址，这是我搭建好的tftp服务器（后续搭建公共的）
     filename                        "pxelinux/pxelinux.0";   #设置TFTP需要下载的文件。这里我也在tftp服务器上配置好了
}
EOF

# 检查dhcp服务是否正常起来
systemctl start dhcpd
netstat -anup | grep dhcp && echo "install and start dhcpd success"
