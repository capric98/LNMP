#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

Basepath=$(cd `dirname $0`; pwd)
apt-get install -y apt-transport-https ca-certificates lsb-release
apt-key adv --fetch-keys 'https://packages.sury.org/php/apt.gpg' > /dev/null 2>&1

apt-get update >> /dev/null
PHP_VER=8.2

echo "Installing PHP-FPM ${PHP_VER}..."
apt install -y php${PHP_VER}-fpm php${PHP_VER}-common \
    php${PHP_VER}-curl \
    php${PHP_VER}-gd \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-mysql \
    php${PHP_VER}-opcache \
    php${PHP_VER}-soap \
    php${PHP_VER}-sqlite3 \
    php${PHP_VER}-xml \
    php${PHP_VER}-zip

sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=0/g" /etc/php/${PHP_VER}/fpm/php.ini
sed -i "s/user = www-data/user = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.owner = www-data/listen.owner = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.group = www-data/listen.group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
service php${PHP_VER}-fpm restart

cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
echo -e "    fastcgi_pass   unix:/run/php/php-fpm${PHP_VER}.sock;
}" >> /usr/local/nginx/conf/enable-php.conf
