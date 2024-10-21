#!/bin/bash

# Check the status of nginx
echo "Checking Nginx status..."
if sudo systemctl is-active --quiet nginx; then
    echo "Nginx is running, skipping Nginx recovery."
else
    echo "Nginx is not running. Attempting to recover..."
    
    sudo systemctl status nginx
    sudo mkdir -p /var/log/nginx
    sudo touch /var/log/nginx/access.log
    sudo touch /var/log/nginx/error.log

    sudo chown -R www-data:www-data /var/log/nginx
    sudo chmod -R 755 /var/log/nginx

    if sudo nginx -t; then
        echo "Nginx configuration is valid. Restarting Nginx..."
        sudo systemctl restart nginx
        echo "Nginx restarted successfully."
    else
        echo "Nginx configuration is invalid. Please check the configuration."
    fi
fi

# Check the status of MySQL
echo "Checking MySQL status..."
if sudo systemctl is-active --quiet mysql; then
    echo "MySQL is running, skipping MySQL recovery."
else
    echo "MySQL is not running. Attempting to recover..."
    
    sudo systemctl status mysql
    sudo apt-get remove --purge mysql-server mysql-client mysql-common -y
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    sudo apt-get install mysql-server -y
fi

# Check if PHP is installed
echo "Checking PHP installation..."
if command -v php > /dev/null; then
    echo "PHP is installed. Checking if it's active..."
    
    # Check PHP version
    if php -v > /dev/null; then
        echo "PHP is active."
    else
        echo "PHP is installed but not active."
    fi
else
    echo "PHP is not installed."
fi

# Get the currently running PHP version
php_version=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")

# Check if PHP-FPM is active (using the dynamic PHP version)
php_fpm_service="php${php_version}-fpm"
echo "Checking PHP-FPM status using service: $php_fpm_service..."
if sudo systemctl is-active --quiet "$php_fpm_service"; then
    echo "PHP-FPM is running, skipping PHP-FPM recovery."
else
    echo "PHP-FPM is not running. Attempting to recover..."
    
    sudo systemctl start "$php_fpm_service"
    if sudo systemctl is-active --quiet "$php_fpm_service"; then
        echo "PHP-FPM started successfully."
    else
        echo "Failed to start PHP-FPM."
    fi
fi

