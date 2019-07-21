#!/bin/bash
apt-get update >> /dev/null
apt-get install -y lsb-release >> /dev/null
# Ubuntu 16.04 mysql-server         -> mysql5.7
# Ubuntu 18.04 default-mysql-server -> mysql5.7
# Debian 9     default-mysql-server -> mariadb
# Debian 10    default-mysql-server -> mariadb
#if [[ $(lsb_release -sc)=="xenial" ]]; then
#    apt install -y mysql-server
#else
#    apt install -y default-mysql-server
#fi

#mysql_secure_installation

echo -ne "\033[44;37mWould you like to edit mysql-server?(y/n)\033[0m"
read -n1 isEditMySQL
echo ""
case ${isEditMySQL} in
    [yY][eE][sS]|[yY])
    bash EditMySQL.sh
    ;;
    *)
    echo -e "\n\033[44;37mOkay~ \033[0m"
    ;;
esac
