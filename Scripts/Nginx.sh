#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

NGINX_VER="1.20.1"
OPENSSL_VER=""


Basepath=$(cd `dirname $0`; pwd)


cd /root

if ! grep -q "^${group}:" /etc/group; then
    echo 'Add group www'
    groupadd -r www >> /dev/null
fi
if ! id "www" &>/dev/null; then
    echo 'Add user www'
    useradd -r -g www -s /sbin/nologin -d /home/www -M www
    mkdir -p /home/www
    chown -R www:www /home/www
fi



apt-get update >> /dev/null
apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git libssl-dev wget
wget --no-check-certificate https://nginx.org/download/nginx-${NGINX_VER}.tar.gz && tar xzf nginx-${NGINX_VER}.tar.gz && rm -rf nginx-${NGINX_VER}.tar.gz
cd nginx-${NGINX_VER}/
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli && git submodule update --init && cd ../

if [ -z "${OPENSSL_VER}" ]
then
    echo "Using default libssl-dev..."
    ./configure --user=www --group=www --prefix=/usr/local/nginx \
        --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
        --with-http_gzip_static_module --with-http_sub_module \
        --with-stream --with-stream_ssl_module \
        --add-module=./ngx_brotli
else
    echo "Using Openssl ${OPENSSL_VER}..."
    wget --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz && tar xzf openssl-${OPENSSL_VER}.tar.gz && rm -rf openssl-${OPENSSL_VER}.tar.gz
    ./configure --user=www --group=www --prefix=/usr/local/nginx \
        --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module \
        --with-http_gzip_static_module --with-http_sub_module \
        --with-stream --with-stream_ssl_module \
        --with-openssl=openssl-${OPENSSL_VER} \
        --add-module=./ngx_brotli
fi


make -j$(nproc)

if [ -f "/usr/local/nginx/conf/nginx.conf" ]; then
    echo "nginx exists!"
    nginx -V
    echo ""
    echo "Upgrading..."

    rm -rf /usr/local/nginx/conf/nginx.conf.default
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.backup
    make install
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.default
    mv /usr/local/nginx/conf/nginx.conf.backup /usr/local/nginx/conf/nginx.conf

    nginx -t && systemctl restart nginx.service
    systemctl status  nginx.service --no-pager
else
    mkdir -p /usr/local/nginx
    rm -rf /usr/sbin/nginx /sbin/nginx

    make install
    ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx
    ln -s /usr/local/nginx/sbin/nginx /sbin/nginx

    mkdir -p /usr/local/nginx/conf/vhost
    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.default
    cp ${Basepath}/../Config/nginx.conf /usr/local/nginx/conf/
    cp ${Basepath}/../Config/nginx.service /lib/systemd/system/nginx.service
    openssl dhparam -dsaparam -out /usr/local/nginx/conf/dhparam.pem 4096

    echo "/usr/local/nginx/logs/*.log {
    monthly
    rotate 2
    size 10M
    compress
    delaycompress
    missingok

    copytruncate
}" > /etc/logrotate.d/nginx

    systemctl enable  nginx.service
    systemctl restart nginx.service
    systemctl status  nginx.service --no-pager
fi

cd $(pwd)

rm -rf /root/nginx-${NGINX_VER}
