#!/bin/bash

confirm_action() {
    # Ask user for confirmation, default to "yes" if they just press Enter
    read -r -p "$1 (Y/n): " response
    [[ -z "$response" || "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
}

print_message() {
    # Print message with a timestamp
    echo -e "\n[$(date +'%Y-%m-%d %H:%M:%S')] $1\n"
}

# Display a menu of available PHP versions
select_php_version() {
    print_message "Available PHP Versions:"
    PS3="Please select the PHP version to install: "

    # Add new PHP versions to the options list
    options=("php7.4" "php8.0" "php8.1" "php8.2" "php8.3" "php8.4" "Enter custom version" "Quit")
    select version in "${options[@]}"; do
        case $version in
            "php7.4"|"php8.0"|"php8.1"|"php8.2"|"php8.3"|"php8.4")
                echo "You selected $version"
                PHP_VERSION="$version"
                break
                ;;
            "Enter custom version")
                # Prompt user for custom PHP version
                read -r -p "Enter the PHP version you want to install (e.g., php8.1): " custom_version
                if [[ -z "$custom_version" ]]; then
                    echo "No version entered. Please try again."
                    continue
                fi
                PHP_VERSION="$custom_version"
                break
                ;;
            "Quit")
                echo "Installation cancelled."
                exit 0
                ;;
            *) echo "Invalid option. Please select a valid PHP version.";;
        esac
    done
}

# Check if PHP is already installed
if command -v php &>/dev/null; then
    CURRENT_PHP_VERSION=$(php -v | head -n 1 | awk '{print $2}')
    print_message "PHP is already installed. Current version: $CURRENT_PHP_VERSION"
    
    if confirm_action "Do you want to install a different version of PHP?"; then
        # Prompt user to select a PHP version
        select_php_version
    else
        print_message "PHP installation skipped."
        exit 0
    fi
else
    if confirm_action "PHP is not installed. Do you want to install PHP and extensions?"; then
        # Prompt user to select a PHP version
        select_php_version
    else
        print_message "PHP installation skipped by user."
        exit 0
    fi
fi

# Proceed with the installation of the selected PHP version and extensions
print_message "Installing $PHP_VERSION and Extensions..."

# Install software properties and repository
sudo apt-get install -y software-properties-common gnupg2 || {
    echo "Failed to install prerequisites"; exit 1;
}

# Add PHP repository
sudo add-apt-repository ppa:ondrej/php -y || {
    echo "Failed to add PHP repository"; exit 1;
}

# Update package list
sudo apt update || {
    echo "Failed to update package list"; exit 1;
}

# Install the selected PHP version and extensions
sudo apt install -y "$PHP_VERSION" "$PHP_VERSION-cli" "$PHP_VERSION-fpm" "$PHP_VERSION-mbstring" \
    "$PHP_VERSION-xml" "$PHP_VERSION-curl" "$PHP_VERSION-zip" "$PHP_VERSION-mysql" "$PHP_VERSION-intl" \
    "$PHP_VERSION-bcmath" || {
    echo "Failed to install $PHP_VERSION and extensions"; exit 1;
}

print_message "$PHP_VERSION and Extensions Installed Successfully"
