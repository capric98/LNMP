#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
apt-get install -y lsb-release
if [[ $(lsb_release -a 2>/dev/null | grep Description | cut -f 2 | cut -d' ' -f1)=="Debian" ]]; then
	if [[ $(lsb_release -sc) -ne "buster" ]]; then
		apt-get install -y apt-transport-https ca-certificates
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
	fi
fi

apt-get update >> /dev/null
PHP_VER=$(aptitude versions php-fpm | head -n 1 | cut -d':' -f2 | cut -d'+' -f1)
echo "Installing PHP-FPM ver${PHP_VER}..."
apt install -y php-fpm php-common php-curl php-mbstring php-mysql
#cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php/${PHP_VER}/fpm/php.ini
sed -i "s/user = www-data/user = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.owner = www-data/listen.owner = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
sed -i "s/listen.group = www-data/listen.group = www/g" /etc/php/${PHP_VER}/fpm/pool.d/www.conf
service php${PHP_VER}-fpm restart
