# LNMP
Compile nginx with OpenSSL_1.1.1&ngx_brotli to support brotli compress and TLSv1.3. Then install php-fpm&mysql from apt source(optional).

This script could support Debian 8/9/10 and Ubuntu 16.04/18.04, but please make sure that you have not installed nginx/php/mysql before, since the script would not check it and the residue may cause problem.

The nginx will be installed to /usr/local/nginx/sbin/nginx, while the config file is /usr/local/nginx/conf/nginx.conf and /usr/local/nginx/conf/vhost/*.conf, and the nginx would run as user "www" of group "www". I changed the php-fpm config file(/etc/php/${PHP_VER}/fpm/pool.d/www.conf) to make it running as user "www".

## Usage
```bash
git clone https://github.com/DeveloperHZH/LNMP
cd LNMP
./Go.sh
```

## Sample vhost config of nginx.
./Config/Sample.config:
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name {YOUR SERVER NAME} ;
    return 302 https://$server_name$request_uri;
    # In case the browser cache it while we need to edit something, do not use 301.
}
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {YOUR SERVER NAME HERE} ;
    index index.html index.htm index.php;
    root  /home/www/homepage;

    ssl_early_data            on;
    ssl_certificate           {YOUR CERTIFICATE FILE};
    ssl_certificate_key       {YOUR CERTIFICATE KET FILE};
    ssl_protocols             TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               'TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-CCM8:ECDHE-ECDSA-AES256-CCM:ECDHE-ECDSA-AES128-CCM:ECDHE-ECDSA-AES128-CCM8';
    ssl_ecdh_curve            secp384r1;
    add_header                Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    ssl_session_cache         builtin:1000 shared:SSL:10m;
    ssl_session_timeout       6h;
    ssl_dhparam               dhparam.pem;

    access_log logs/homepage.log;
}
```

# LNMP
使用OpenSSL_1.1.1和ngx_brotli编译nginx来支持br压缩以及TLSv1.3，并从apt源安装php-fpm和mysql（可选）。

该脚本支持Debian 8/9/10和Ubuntu 16.04/18.04（虽然我没测试>_<）， 请保证系统纯净未安装过nginx/php/mysql，否则残留文件可能导致安装失败，该脚本不会检测系统是否已安装对应包。。

nginx被安装在/usr/local/nginx/sbin/nginx，配置文件则位于/usr/local/nginx/conf/nginx.conf和/usr/local/nginx/conf/vhost/*.conf；nginx以www用户组下www用户运行，为保持一致已将php的配置文件对应用户、用户组改为www。
## 用法
```bash
git clone https://github.com/DeveloperHZH/LNMP
cd LNMP
./Go.sh
```

## nginx vhost样例配置文件
./Config/Sample.config
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name {YOUR SERVER NAME} ;
    return 302 https://$server_name$request_uri;
    # In case the browser cache it while we need to edit something, do not use 301.
}
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {YOUR SERVER NAME HERE} ;
    index index.html index.htm index.php;
    root  /home/www/homepage;

    ssl_early_data            on;
    ssl_certificate           {YOUR CERTIFICATE FILE};
    ssl_certificate_key       {YOUR CERTIFICATE KET FILE};
    ssl_protocols             TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers               'TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-CCM8:ECDHE-ECDSA-AES256-CCM:ECDHE-ECDSA-AES128-CCM:ECDHE-ECDSA-AES128-CCM8';
    ssl_ecdh_curve            secp384r1;
    add_header                Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    ssl_session_cache         builtin:1000 shared:SSL:10m;
    ssl_session_timeout       6h;
    ssl_dhparam               dhparam.pem;

    access_log logs/homepage.log;
}
```
