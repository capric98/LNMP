#!/bin/bash
sed -i "/PS1='$/d" ~/.bashrc
echo "TZ='Asia/Shanghai'; export TZ" >> ~/.bashrc
rm -rf /etc/localtime && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "PS1='\${debian_chroot:+($debian_chroot)}\[\e[1;31m\]\u\[\e[1;33m\]@\[\e[1;36m\]\h \[\e[1;33m\]\w \[\e[1;35m\]\\\$ \[\e[0m\]'" >> ~/.bashrc

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod -R 600 ~/.ssh

sed -i "s/\# export LS_OPTIONS='--color=auto'/export LS_OPTIONS='--color=auto'/g" ~/.bashrc
sed -i "s/\# eval \"\`dircolors\`\"/eval \"\`dircolors\`\"/g" ~/.bashrc
sed -i "s/\# alias ls='ls \$LS_OPTIONS'/alias ls='ls \$LS_OPTIONS'/g" ~/.bashrc
sed -i "s/\# alias ll='ls \$LS_OPTIONS -l'/alias ll='ls \$LS_OPTIONS -l'/g" ~/.bashrc
sed -i "s/\# alias l='ls \$LS_OPTIONS -lA'/alias l='ls \$LS_OPTIONS -lA'/g" ~/.bashrc
sed -i '/vm.swappiness/d' /etc/sysctl.conf
sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
sed -i '/fs.file-max/d' /etc/sysctl.conf
sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
sed -i '/net.core.rmem_default/d' /etc/sysctl.conf
sed -i '/net.core.wmem_default/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_rmem/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_mtu_probing/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_syn_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
sed -i '/net.ipv4.route.gc_timeout/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
sed -i '/net.core.somaxconn/d' /etc/sysctl.conf
sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_timestamps/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_max_orphans/d' /etc/sysctl.conf
sed -i '/net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf
echo "vm.swappiness = 10
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_rmem = 4096    524000  67110000
net.ipv4.tcp_wmem = 4096    524000  67110000
net.ipv4.tcp_mem  = 1541547 2055396 3083094
net.ipv6.conf.all.forwarding=1
net.core.netdev_max_backlog = 32768
net.core.rmem_max = 12582912
net.core.somaxconn = 32768
net.core.wmem_max = 12582912
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
sysctl -p

apt-get update >> /dev/null
apt install -y cpufrequtils vim unattended-upgrades apt-listchanges
echo -e "set mouse-=a
# Code Highlighting
syntax on
colorscheme slate
# Remeber Cursor
if has(\"autocmd\")
  au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif
endif" > ~/.vimrc
echo 'GOVERNOR="performance"' | tee /etc/default/cpufrequtils
/etc/init.d/cpufrequtils restart
