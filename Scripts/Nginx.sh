#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
NGINX_VER="1.15.12"
cd /root
groupadd -r www && useradd -r -g www -s /sbin/nologin -d /usr/local/nginx -M www
mkdir -p /usr/local/nginx

apt-get update >> /dev/null
apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git
apt install -y sysv-rc-conf
wget --no-check-certificate http://nginx.org/download/nginx-${NGINX_VER}.tar.gz && tar xzf nginx-${NGINX_VER}.tar.gz && rm -rf nginx-${NGINX_VER}.tar.gz
cd nginx-${NGINX_VER}/
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli && git submodule update --init && cd ../
wget --no-check-certificate https://github.com/openssl/openssl/archive/OpenSSL_1_1_1c.zip && unzip OpenSSL_1_1_1c.zip && rm -rf OpenSSL_1_1_1c.zip
mv openssl-OpenSSL_1_1_1c/ openssl-1_1_1c/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-openssl=./openssl-1_1_1c --add-module=./ngx_brotli
make -j$(nproc) && make install
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

mkdir -p /usr/local/nginx/conf/vhost
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
rm -rf /usr/local/nginx/conf/nginx.conf /root/nginx-${NGINX_VER}
cp ${Basepath}/../Config/nginx.conf /usr/local/nginx/conf/
cp ${Basepath}/../Config/nginx /etc/init.d/ #&& ln -s /etc/init.d/nginx /etc/rc5.d/S01nginx
#cp ${Basepath}/../Config/fake.* /usr/local/nginx/conf/
#cp ${Basepath}/../Config/ForbidIP443.conf /usr/local/nginx/conf/vhost/
openssl dhparam -dsaparam -out /usr/local/nginx/conf/dhparam.pem 4096
sysv-rc-conf nginx on
update-rc.d nginx defaults
service nginx restart
