#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
apt install -y php7.2-fpm
cp ${Basepath}/../Config/enable-php.conf /usr/local/nginx/conf/
sed -i "s/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g" /etc/php/7.2/fpm/php.ini
chmod -R 644 /var/run/php/
