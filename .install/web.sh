#!/bin/bash
#
# ~/.install/web.sh (Linux server)
#
#   Webserver auto install, config, & setup script.
#   Includes only Nginx and PHP for the webserver, though a database
#   software like MySQL or something may be added here in the future.
#
#     Neel Yadav
#     07.16.2021


ubuntu_ver="$(lsb_release -sr)"
[[ $ubuntu_ver == 20* ]] && phpv="7.4"
[[ $ubuntu_ver == 18* ]] && phpv="7.2"
if [[ "$(id -u)" -ne 0 ]]; then
    echo "——abort: install script should be run with sudo privileges"
    exit 11
elif [[ -z $phpv ]]; then
    echo -e "Ubuntu release: $ubuntu_ver ...\nbro, what're u doin"
    exit 11
fi


# ————Nginx install & config———————————————————————————————————————————
echo -e "\n  ——NGINX——\n"
apt install -y nginx-extras certbot
systemctl start nginx
systemctl enable nginx
ufw allow 'Nginx Full'; ufw reload

if [[ ! -f /etc/nginx/dhbits.pem ]]; then
    dd if=/dev/random of=/dev/urandom bs=1 count=32 2> /dev/null; pollinate -r
	openssl dhparam -out /etc/nginx/dhbits.pem 2048
fi

cat <<'END' > /etc/nginx/conf.d/ssl.conf
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
ssl_dhparam /etc/nginx/dhbits.pem;
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_buffer_size 1400; # nginx 1.5.9+ only
ssl_stapling off;
ssl_stapling_verify on;
resolver 1.1.1.1 valid=86400; # change this later
resolver_timeout 10;
END

grep -q "charset" /etc/nginx/nginx.conf || sed -i -E '/sendfile on;$/i\\tcharset utf-8;' /etc/nginx/nginx.conf
sed -i -E 's/(# )?(server_tokens) .*/\2 off;/' /etc/nginx/nginx.conf
sed -i -E 's/(# )?(ssl_protocols) .*/\2 TLSv1.2 TLSv1.3;/' /etc/nginx/nginx.conf
sed -i -E 's/(# )?(server_names_hash_bucket_size) .*/\2 128;/' /etc/nginx/nginx.conf

mkdir /var/www/_certbot

# ————PHP install and setup w/ Nginx———————————————————————————————————
echo -e "\n  ——PHP——\n"
apt install -y php${phpv}-common php${phpv}-cli php${phpv}-curl php${phpv}-json php${phpv}-fpm php${phpv}-dev idn2
sed -i -E 's/expose_php.*/expose_php = Off/' /etc/php/${phpv}/fpm/php.ini
systemctl start php${phpv}-fpm
systemctl enable php${phpv}-fpm

public_ip="$(curl -s -4 icanhazip.com)"
cat <<END > /etc/nginx/sites-available/php-test.conf
server {
    listen 80;
    server_name ${public_ip};
    root /var/www/html;

    index index.html index.htm index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php${phpv}-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }
}
END
echo '<?php phpinfo();' > /var/www/html/info.php
ln -s /etc/nginx/sites-available/php-test.conf /etc/nginx/sites-enabled/
[[ -e /etc/nginx/sites-enabled/default ]] && unlink /etc/nginx/sites-enabled/default
nginx -t && systemctl restart php${phpv}-fpm nginx

echo -e "\n————\e[1m\n\nWeb server setup complete! \nTest Nginx/PHP setup by visiting http://${public_ip}/info.php\e[0m"
echo -e "\e[1m\nYou should see a PHP info page. If you do, it works! \nNow, \e[4mFOR SECURITY PROMPTLY DELETE\e[0;1m /var/www/html/info.php\e[0m\n\n————\n"
