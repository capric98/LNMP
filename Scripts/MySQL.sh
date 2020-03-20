#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

apt-get update >> /dev/null
apt-get install -y lsb-release >> /dev/null
# Ubuntu 16.04 mysql-server         -> mysql5.7
# Ubuntu 18.04 default-mysql-server -> mysql5.7
# Debian 9     default-mysql-server -> mariadb
# Debian 10    default-mysql-server -> mariadb
if [[ $(lsb_release -sc) == "xenial" ]]; then
    apt install -y mysql-server
else
    apt install -y default-mysql-server
fi

mysql_secure_installation
