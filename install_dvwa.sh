#!/bin/bash

### Variables
USERDB='dvwa'
PASSDB='password'
LEVELUP='low'

echo -e "Installing packages..."
apt update && apt full-upgrade -y
apt install -y apache2 mariadb-server php
apt install -y php-mysqli php-gd libapache2-mod-php

rm -rf /var/www/html/index.html

echo -e "Downloading dvwa..."
git -C /var/www/html/ clone https://github.com/ethicalhack3r/dvwa.git

cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php

echo -e "Copying dvwa config..."
sed -i "s/$_dvwa\[ 'db_user' \]     = 'dvwa';/$_dvwa\[ 'db_user' \]     = '${USERDB}';/g" /var/www/html/dvwa/config/config.inc.php
sed -i "s/$_dvwa\[ 'db_password' \] = 'p@ssw0rd';/$_dvwa\[ 'db_password' \] = '${PASSDB}';/g" /var/www/html/dvwa/config/config.inc.php
sed -i "s/$_dvwa\[ 'default_security_level' \] = 'impossible';/$_dvwa\[ 'default_security_level' \] = '${LEVELUP}';/g" /var/www/html/dvwa/config/config.inc.php

echo -e "Configuring PHP..."
sed -i 's/allow_url_include = Off/allow_url_include = On/g' /etc/php/7.4/apache2/php.ini

echo -e "Changing permissions for dvwa directory..."
chown -R www-data:www-data /var/www/html/dvwa/hackable
chown -R www-data:www-data /var/www/html/dvwa/external
chown -R www-data:www-data /var/www/html/dvwa/config

echo -e "Configuring DB..."
mysql -u root -e "create database dvwa;"
sleep 2
mysql -u root -e "create user ${USERDB}@localhost identified by '${PASSDB}';"
sleep 2
mysql -u root -e "grant all on dvwa.* to ${USERDB}@localhost;"
sleep 2
mysql -u root -e "flush privileges;"

systemctl restart apache2

echo -e "Setting up dvwa database..."
TOKEN=$(curl -s -c /tmp/unk9.vvn "127.0.0.1/DVWA/setup.php" | awk -F 'value=' '/user_token/ {print $2}' | cut -d "'" -f2)
curl 'http://127.0.0.1/dvwa/setup.php' -H 'Host: 127.0.0.1' --data "create_db=Create+%2F+Reset+Database&user_token=${TOKEN}"

echo -e "Done. Opening dvwa in your browser : 'http://<IP>/dvwa/login.php'"
