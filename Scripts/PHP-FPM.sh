#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
apt install -y lsb-release
if [[ $(lsb_release -a 2>/dev/null | grep Description | cut -f 2 | cut -d' ' -f1)=="Debian" ]]; then
	apt install -y apt-transport-https ca-certificates
	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
fi

apt update >> /dev/null
apt install -y php7.2-fpm php7.2-curl
cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php/7.2/fpm/php.ini
sed -i "s/user = www-data/user = www/g" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = www/g" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/listen.owner = www-data/listen.owner = www/g" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/listen.group = www-data/listen.group = www/g" /etc/php/7.2/fpm/pool.d/www.conf
service php7.2-fpm restart
