#!/usr/bin/env bash

set -e

yum install -y tftp-server xinetd syslinux
systemctl enable xinetd tftp

sed -i -c -e '/disable/s/\<yes\>/no/' /etc/xinetd.d/tftp
mkdir -p /var/lib/tftpboot/pxelinux/pxelinux.cfg
cp -r /usr/share/syslinux/* /var/lib/tftpboot/pxelinux

# pxelinux默认配置文件
PXE_CFG=/var/lib/tftpboot/pxelinux/pxelinux.cfg/default

# TODO: 修改这个配置,以及initrd.img和vmlinuz
if [[ ! -f $PXE_CFG ]]; then
cat > $PXE_CFG << EOF
default menu.c32
timeout 300
menu title kylin

menu title ########## PXE Boot Menu ##########

label local
  menu default
  menu label Boot from ^local drive
  localboot 0xffff

# 配置启动参考isolinux.cfg
# 还需要将iso目录中的images/pxeboot相关启动内核镜像放到tftp服务器中image/ksvd-818目录中
label -ksvd-818
  menu label ^Install KSVD-818 x64
  kernel image/ksvd-818/vmlinuz
  append initrd=image/ksvd-818/initrd.img method=http://192.168.56.2/ksvd-818 ks=http://192.168.56.2/ksvd-818/kickstart/ks.cfg devfs=nomount inst.vnc inst.vncpassword=ksvd2020
EOF
fi

systemctl start xinetd tftp
netstat -anup | grep -w 69 && echo "success install and start tftp"
