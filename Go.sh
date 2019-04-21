#!/bin/bash
echo -e "\033[44;37mNginx is forced to compile and install. \033[0m"
echo -ne "\033[44;37mWould you like to install php-fpm?(y/n)\033[0m"
read -n1 isInstallPHP
case ${isInstallPHP} in
    [yY][eE][sS]|[yY])
    echo -e "\n\033[44;37mかしこまりました！Will install php-fpm. \033[0m"
    isInstallPHP=1
    ;;
    [nN][oO]|[nN])
    echo -e "\n\033[44;37mOK, do not install php-fpm.             \033[0m"
    isInstallPHP=0
    ;;
    *)
    echo -e "\n\033[44;37mOther input, do not install php-fpm.    \033[0m"
    isInstallPHP=0
    ;;
esac
echo -ne "\033[44;37mWould you like to install MySQL?(y/n)  \033[0m"
read -n1 isInstallMySQL
case ${isInstallMySQL} in
    [yY][eE][sS]|[yY])
    echo -e "\n\033[44;37mかしこまりました！Will install MySQL.   \033[0m"
    isInstallMySQL=1
    ;;
    [nN][oO]|[nN])
    echo -e "\n\033[44;37mOK, do not install MySQL.               \033[0m"
    isInstallMySQL=0
    ;;
    *)
    echo -e "\n\033[44;37mOther input, do not install MySQL.      \033[0m"
    isInstallMySQL=0
    ;;
esac

Scripts/Nginx.sh
if [ ${isInstallPHP} -eq 1 ]
then
    echo -e "\033[44;37mStart to install php-fpm...\033[0m"
    Scripts/PHP-FPM.sh
fi
if [ ${isInstallMySQL} -eq 1 ]
then
    echo -e "\033[44;37mStart to install mysql...     \033[0m"
    echo -e "\033[44;37mThis function is not finished.\033[0m"
    Scripts/MySQL.sh
fi
