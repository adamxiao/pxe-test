# centos准备pxe server环境

refer http://k8s.unixhot.com/cobbler/kickstart.html#local

FAQ:

1. 禁用防火墙, 禁用selinux
2. 原来问题出在内存，pxe装机内存最少要2个G！！！！！非常简单问题，就忽视了！！！
3. firewalld 可能阻止了自己br0的包
echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables

