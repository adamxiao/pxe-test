yum install -y dnsmasq

cat > /etc/dnsmasq.conf <<EOF
interface=eth0,lo
bind-interfaces
domain=adam-centos

dhcp-range=ens33,192.168.56.230,192.168.56.253,255.255.255.0,1h
dhcp-option=3,192.168.56.1
dhcp-option=6,192.168.56.1
dhcp-option=6,8.8.8.8
server=8.8.4.4
dhcp-option=28,10.0.0.255
dhcp-option=42,0.0.0.0

dhcp-boot=pxelinux/pxelinux.0,pxeserver,192.168.56.2

pxe-prompt="Press F8 for menu.", 2
pxe-service=x86PC, "Install Ubuntu 16.04 from network server 192.168.1.14", pxelinux
enable-tftp
tftp-root=/srv/tftp

EOF


cp /etc/sysconfig/network-scripts/ifcfg-eth0 /root/ifcft-eth0.dhcp
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
BOOTPROTO=static
DEVICE=eth0
ONBOOT=yes
STARTMODE=auto
TYPE=Ethernet
USERCTL=no
IPADDR=192.168.56.3
PREFIX=24
GATEWAY=192.168.56.1
DNS1=114.114.114.114
EOF
