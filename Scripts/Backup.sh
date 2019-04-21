#!/bin/bash
list="wordpress typecho"
PASSWD="4GfcAPs413S7V2BA"
homeDir="/home/wwwroot"
tmpDir=$(cd `dirname $0`; pwd)

mkdir -p "$tmpDir"/websites
cp -r "$homeDir"/* "$tmpDir"/websites/
mkdir -p "$tmpDir"/mysql
for DB_name in $list; do
        /usr/bin/mysqldump -uroot -p${PASSWD} ${DB_name} >> "$tmpDir"/mysql/${DB_name}.sql 2>/dev/null
done

DATE=$(date +%Y-%m-%d)
cd "$tmpDir"
/usr/bin/zip -P This_is_Passw0rd -r ${DATE}-backup.zip websites mysql
rm -rf "$tmpDir"/websites "$tmpDir"/mysql

/usr/bin/rclone copy -v --stats 5s "$tmpDir"/${DATE}-backup.zip GD:/WebsiteBackup/

