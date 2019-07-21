#!/bin/bash
Create_Database () {
    mysql -uroot -p"${sql_pass}" -e "CREATE DATABASE $1 CHARACTER SET utf8 COLLATE utf8_bin;" 2>>/dev/null
}
Add_User () {
    mysql -uroot -p"${sql_pass}" -e "CREATE USER '$1'@'localhost' IDENTIFIED BY '$2';" 2>>/dev/null
}
GRANT_User_To () {
    mysql -uroot -p"${sql_pass}" -e "GRANT ALL PRIVILEGES ON $2.* to $1@localhost;" 2>>/dev/null
    mysql -uroot -p"${sql_pass}" -e "FLUSH PRIVILEGES;" 2>>/dev/null
}

echo -e "\033[44;37mYou need to input MySQL root password:   \033[0m"
read -s sql_pass
echo ""
echo ""

while :
do
    sleep 1
    echo -e "\033[44;37m0. Exit this script.       \033[0m"
    echo -e "\033[44;37m1. Create a database.      \033[0m"
    echo -e "\033[44;37m2. Create a user.          \033[0m"
    echo -e "\033[44;37m3. Grant user's privileges.\033[0m"
    echo -ne "\033[44;37mChoose an operation:      \033[0m"
    read -n1 op
    echo ""
    case ${op} in
        [0])
            exit
        ;;
        [1])
            echo -e "\033[44;37mInput the name of database:\033[0m"
            read database_name
            Create_Database "${database_name}"
        ;;
        [2])
            echo -e "\033[44;37mInput the username:        \033[0m"
            read username
            echo -e "\033[44;37mInput the user's password: \033[0m"
            read upass
            Add_User "${username}" "${upass}"
        ;;
        [3])
            echo -e "\033[44;37mInput the username:        \033[0m"
            read username
            echo -e "\033[44;37mInput the name of database:\033[0m"
            read database_name
            GRANT_User_To "${username}" "${database_name}"
        ;;
        *)
            echo -e "\033[44;37mUnknown operation!         \033[0m"
        ;;
    esac
    mysql -uroot -p"${sql_pass}" -e "show databases;" 2>>/dev/null
done
