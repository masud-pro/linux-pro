#!/bin/bash

# Check if PHP is already installed
php_installed=false
if command -v php &> /dev/null; then
    php_installed=true
    echo "PHP is already installed. Current version: $(php -v | head -n 1)"
fi

# Prompt user for action if PHP is installed
if $php_installed; then
    echo "What would you like to do?"
    echo "1) Install a different PHP version"
    echo "2) Ignore PHP installation"
    echo "3) Reinstall/Update PHP"
    read -p "Please choose an option (1/2/3): " php_choice

    case $php_choice in
        1)
            echo "Proceeding with PHP version selection..."
            ;;
        2)
            echo "Skipping PHP installation."
            php_skip=true
            ;;
        3)
            echo "Reinstalling/updating PHP..."
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
fi

# If skipping PHP installation, only install Composer
if [ "$php_skip" == true ]; then
    # Install Composer
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer

    # Verify Composer installation
    echo "Composer version installed:"
    composer --version
    echo "Composer installation complete!"
    exit 0
fi

# Define available PHP versions
php_versions=("7.4" "8.0" "8.1" "8.2" "Quit")

# Display the options menu
echo "Select the PHP version you want to install:"
select php_version in "${php_versions[@]}"; do
    case $php_version in
        "7.4"|"8.0"|"8.1"|"8.2")
            echo "You selected PHP $php_version"
            break
            ;;
        "Quit")
            echo "Installation cancelled."
            exit
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

# Update package list
echo "Updating package list..."
sudo apt update

# Add PHP repository if needed
echo "Adding PHP repository..."
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# Install the selected PHP version and common extensions
echo "Installing PHP $php_version and common extensions..."
sudo apt install -y php$php_version php$php_version-cli php$php_version-fpm php$php_version-mbstring php$php_version-xml php$php_version-curl php$php_version-zip php$php_version-gd php$php_version-mysql

# Verify installation
echo "PHP $php_version installed:"
php$php_version -v

# Set default PHP version (optional)
echo "Do you want to set PHP $php_version as the default PHP version? (y/n):"
read set_default

if [[ "$set_default" == "y" ]]; then
    sudo update-alternatives --set php /usr/bin/php$php_version
    echo "PHP $php_version set as the default version."
fi

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Verify Composer installation
echo "Composer version installed:"
composer --version

echo "PHP $php_version and Composer installation complete!"
