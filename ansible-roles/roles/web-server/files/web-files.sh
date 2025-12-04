sudo rm -rf /var/www/*
sudo mv /tmp/html5up-phantom/ /var/www/
sudo mv /tmp/html5up-editorial/ /var/www/
sudo find /var/www/ -type d -exec chmod 755 {} \;
sudo find /var/www/html5up-phantom/ -type f -exec chmod 644 {} \;
sudo find /var/www/html5up-editorial/ -type f -exec chmod 644 {} \;
sudo systemctl restart nginx
