#!/usr/bin/env bash

# TODO: 
# 1. 构建pxe安装源

set -e

yum install -y httpd createrepo
systemctl enable httpd

ksvd_dir=/var/www/html/ksvd-818
mkdir -p $ksvd_dir

# 将pxe安装镜像放到$ksvd_dir中, 可以直接mount iso, 或可以mount光驱
# mount xxx.iso $ksvd_dir
# mount /dev/sr0 $ksvd_dir

# 附上直接安装ksvd-818-server的方法
# 参考 https://blog.csdn.net/evglow/article/details/104040243
# 删除Package中的KSVD几个rpm，替换为818-server的几个KSVD rpm包
# 然后重新生成软件源仓库
# createrepo -d -g repodata/*.comps.xml .

systemctl start httpd
netstat -lntp | grep httpd && echo "install and start httpd success"
