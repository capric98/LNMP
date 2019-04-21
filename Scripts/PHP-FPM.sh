#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
apt install -y php7.2-fpm php7.2-curl
cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php/7.2/fpm/php.ini
sed -i "s/user = www-data/user = www/g" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = www/g" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/listen.owner = www-data/listen.owner = www" /etc/php/7.2/fpm/pool.d/www.conf
sed -i "s/listen.group = www-data/listen.group = www" /etc/php/7.2/fpm/pool.d/www.conf
service php7.2-fpm restart
