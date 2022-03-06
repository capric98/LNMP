#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

NGINX_VER="1.20.2"
OPENSSL_VER="" # 1.1.1m
ZLIB_VER=""    # 1.2.11
PCRE_VER=""    # 8.45

User="www"
Group="www"

Configure_Options="--user=${User} --group=${Group} --prefix=/usr/local/nginx
    --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module
    --with-http_gzip_static_module --with-http_sub_module --with-http_realip_module
    --with-stream --with-stream_ssl_module"

TMPDIR=$(mktemp -d)
Basepath=$(cd `dirname $0`; pwd)

cd ${TMPDIR}

if [ ! $(getent group "${Group}") ]; then
    echo "Add group ${Group}"
    groupadd -r ${Group} >> /dev/null
fi
if ! id "${User}" &>/dev/null; then
    echo "Add user ${User}"
    useradd -r -g ${Group} -s /sbin/nologin -d /home/${User} -M ${User}
    mkdir -p /home/${User}
    chown -R ${User}:${Group} /home/${User}
fi


apt-get update >> /dev/null
apt-get install -y build-essential git wget

wget --no-check-certificate https://nginx.org/download/nginx-${NGINX_VER}.tar.gz && \
    tar xzf nginx-${NGINX_VER}.tar.gz && \
    rm -rf nginx-${NGINX_VER}.tar.gz
cd nginx-${NGINX_VER}/

git clone https://github.com/google/ngx_brotli.git && \
    cd ngx_brotli && \
    git submodule update --init && \
    Configure_Options="${Configure_Options} --add-module=ngx_brotli" && \
    cd ../

if [ -z "${PCRE_VER}" ]
then
    echo "Using default libpcre3-dev..."
    apt-get install libpcre3-dev
else
    wget --no-check-certificate https://nchc.dl.sourceforge.net/project/pcre/pcre/${PCRE_VER}/pcre-${PCRE_VER}.tar.gz && \
        tar -xzvf pcre-${PCRE_VER}.tar.gz && \
        rm -rf pcre-${PCRE_VER}.tar.gz && \
        Configure_Options="${Configure_Options} --with-pcre=pcre-${PCRE_VER}" && \
        echo "Using PCRE ${PCRE_VER}..."
fi

if [ -z "${ZLIB_VER}" ]
then
    echo "Using default zlib1g-dev..."
    apt-get install zlib1g-dev
else
    wget --no-check-certificate https://zlib.net/zlib-${ZLIB_VER}.tar.gz && \
        tar -xzvf zlib-${ZLIB_VER}.tar.gz && \
        rm -rf zlib-${ZLIB_VER}.tar.gz && \
        Configure_Options="${Configure_Options} --with-zlib=zlib-${ZLIB_VER}" && \
        echo "Using zlib ${ZLIB_VER}..."
fi

if [ -z "${OPENSSL_VER}" ]
then
    echo "Using default libssl-dev..."
    apt-get install libssl-dev
else
    wget --no-check-certificate https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz && \
        tar -xzvf openssl-${OPENSSL_VER}.tar.gz && \
        rm -rf openssl-${OPENSSL_VER}.tar.gz && \
        Configure_Options="${Configure_Options} --with-openssl=openssl-${OPENSSL_VER}" && \
        echo "Using Openssl ${OPENSSL_VER}..."
fi

# Configure_Options="${Configure_Options} --with-cc-opt=\"-static -static-libgcc\" --with-ld-opt=\"-static\""

./configure ${Configure_Options}
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

rm -rf ${TMPDIR}