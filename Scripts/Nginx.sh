#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 
   exit 1
fi

Basepath=$(cd `dirname $0`; pwd)
NGINX_VER="1.18.0"
cd /root
mkdir -p /home/www
mkdir -p /usr/local/nginx
rm -rf /usr/sbin/nginx /sbin/nginx
groupadd -r www >> /dev/null
useradd -r -g www -s /sbin/nologin -d /home/www -M www
chown -R www:www /home/www


apt-get update >> /dev/null
apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git libssl-dev wget
wget --no-check-certificate http://nginx.org/download/nginx-${NGINX_VER}.tar.gz && tar xzf nginx-${NGINX_VER}.tar.gz && rm -rf nginx-${NGINX_VER}.tar.gz
cd nginx-${NGINX_VER}/
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli && git submodule update --init && cd ../

./configure --user=www --group=www --prefix=/usr/local/nginx \
    --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
    --with-http_gzip_static_module --with-http_sub_module \
    --with-stream --with-stream_ssl_module \
    --add-module=./ngx_brotli
make -j$(nproc) && make install
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
ln -s /usr/local/nginx/sbin/nginx /sbin/nginx
cd $(pwd)

mkdir -p /usr/local/nginx/conf/vhost
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
cp ${Basepath}/../Config/nginx.conf /usr/local/nginx/conf/
cp ${Basepath}/../Config/nginx.service /lib/systemd/system/nginx.service
openssl dhparam -dsaparam -out /usr/local/nginx/conf/dhparam.pem 4096

rm -rf /root/nginx-${NGINX_VER}

systemctl enable  nginx.service
systemctl restart nginx.service
systemctl status  nginx.service --no-pager


echo "/usr/local/nginx/logs/*.log {
    monthly
    rotate 2
    size 10M
    compress
    delaycompress
    missingok

    copytruncate
}" > /etc/logrotate.d/nginx
