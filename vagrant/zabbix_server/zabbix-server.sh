useradd $1 -s /bin/bash
usermod --password $(openssl passwd -6 $2) root
usermod --password $(openssl passwd -6 $2) $1

apt update
apt install postgresql -y

su - postgres -c 'psql --command "CREATE USER zabbix WITH PASSWORD '\'$3\'';"'

sudo -u postgres createdb -O zabbix zabbix

if [ $4 == "true" ]; then apt upgrade -y; else echo '$4'=$4; fi

wget $5

dpkg -i zabbix-release*.deb

apt update

apt install zabbix-server-pgsql zabbix-frontend-php php7.3-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent nano -y

zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix

sed -i 's/# DBPassword=/DBPassword='$3'/g' /etc/zabbix/zabbix_server.conf

sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
