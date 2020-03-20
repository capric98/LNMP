#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

Basepath=$(cd `dirname $0`; pwd)
apt-get install -y lsb-release aptitude
if [[ $(lsb_release -a 2>/dev/null | grep Description | cut -f 2 | cut -d' ' -f1) == "Debian" ]]; then
	if [[ $(lsb_release -sc) != "buster" ]]; then
		apt-get install -y apt-transport-https ca-certificates
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
	fi
fi

apt-get update >> /dev/null
PHP_VER=$(aptitude versions php-fpm | head -n 1 | cut -d':' -f2 | cut -d'+' -f1)
echo "Installing PHP-FPM ${PHP_VER}..."
apt install -y php${PHP_VER}-fpm php${PHP_VER}-common \
    php${PHP_VER}-curl \
    php${PHP_VER}-gd \
    php${PHP_VER}-json \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-mysql \
    php${PHP_VER}-opcache \
    php${PHP_VER}-soap \
    php${PHP_VER}-sqlite3 \
    php${PHP_VER}-xml \
    php${PHP_VER}-zip
#cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php/${PHP_VER}/fpm/php.ini
sed -i "s/user = www-data/user = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.owner = www-data/listen.owner = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.group = www-data/listen.group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
service php${PHP_VER}-fpm restart

echo -e "location ~ \\.php$ {
    #NOTE: You should have \"cgi.fix_pathinfo = 0;\" in php.ini
    include fastcgi_params;
    fastcgi_intercept_errors on;
    fastcgi_pass unix:/var/run/php/php-fpm${PHP_VER}.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root/\$fastcgi_script_name;
}" > /usr/local/nginx/conf/enable-php.conf
