#!/bin/bash

# Function to print a formatted message
function print_message() {
    echo ""
    echo "======================================"
    echo " $1"
    echo "======================================"
    echo ""
}

# Function to confirm action
function confirm_action() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
        [Yy]*) break ;;
        [Nn]*) return 1 ;;
        *) echo "Please answer yes or no." ;;
        esac
    done
}

# Function to create MySQL user
create_mysql_user() {
    local username=$1
    local password=$2
    local host="localhost"

    print_message "Creating MySQL user '$username' with password authentication"
    mysql -u root -p -e "CREATE USER '$username'@'$host' IDENTIFIED BY '$password';"
    mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$username'@'$host' WITH GRANT OPTION;"
    mysql -u root -p -e "FLUSH PRIVILEGES;"
    print_message "MySQL user '$username' created"
}

# Main script starts here

# Update packages
if confirm_action "Do you want to update system packages?"; then
    print_message "Updating Packages"
    sudo apt update && sudo apt upgrade -y
    print_message "Packages Updated"
fi

# Install core dependencies
if confirm_action "Do you want to install core dependencies (curl, wget, git, etc.)?"; then
    print_message "Installing Core Dependencies"
    sudo apt install -y curl wget git unzip build-essential software-properties-common
    print_message "Core Dependencies Installed"
fi

# Install PHP and necessary extensions
if ! command -v php &>/dev/null; then
    if confirm_action "PHP is not installed. Do you want to install PHP 8.2 and extensions?"; then
        print_message "Installing PHP and Extensions"
        sudo add-apt-repository ppa:ondrej/php -y
        sudo apt update
        sudo apt install -y php8.2 php8.2-cli php8.2-fpm php8.2-mbstring php8.2-xml php8.2-curl php8.2-zip php8.2-mysql php8.2-intl php8.2-bcmath
        print_message "PHP and Extensions Installed"
    fi
else
    print_message "PHP is already installed, skipping."
fi

# Install Composer
if ! command -v composer &>/dev/null; then
    if confirm_action "Composer is not installed. Do you want to install Composer?"; then
        print_message "Installing Composer"
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar ~/.local/bin/composer
        export PATH="$HOME/.local/bin:$PATH"  # Make this change persistent later
        print_message "Composer Installed"
    fi
else
    print_message "Composer is already installed, skipping."
fi

# Install Node.js and npm using NVM
if ! command -v nvm &>/dev/null; then
    if confirm_action "NVM (Node Version Manager) is not installed. Do you want to install NVM and Node.js?"; then
        print_message "Installing NVM (Node Version Manager)"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Load NVM
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash_completion

        print_message "NVM Installed"

        # Install Node.js using NVM
        if confirm_action "Do you want to install Node.js version 22 using NVM?"; then
            print_message "Installing Node.js version 22"
            nvm install 22
            print_message "Node.js version 22 Installed"
        fi
    fi
else
    print_message "NVM is already installed, skipping."

    # Check if Node.js 22 is installed
    if ! nvm list | grep -q 'v22\.'; then
        if confirm_action "Node.js version 22 is not installed. Do you want to install it?"; then
            print_message "Installing Node.js version 22"
            nvm install 22
            print_message "Node.js version 22 Installed"
        fi
    else
        print_message "Node.js version 22 is already installed, skipping."
    fi
fi

# Install MySQL
if ! command -v mysql &>/dev/null; then
    if confirm_action "MySQL is not installed. Do you want to install MySQL?"; then
        print_message "Installing MySQL"
        sudo apt install -y mysql-server
        sudo mysql_secure_installation
        print_message "MySQL Installed"
    fi
else
    print_message "MySQL is already installed, skipping."
fi

# Other installations...

# Clone your Laravel project
read -p "Enter your project repository URL (leave blank to skip): " repo_url
if [ ! -z "$repo_url" ]; then
    print_message "Cloning Laravel Project"
    if [ -d "project-name" ]; then
        print_message "Project directory already exists. Skipping cloning."
    else
        git clone $repo_url project-name
        cd project-name
        print_message "Laravel Project Cloned"
    fi
fi

# Install Laravel dependencies
if [ -d "project-name" ]; then
    cd project-name
    if confirm_action "Do you want to install Laravel dependencies?"; then
        print_message "Installing Laravel Dependencies"
        composer install
        npm install
        print_message "Laravel Dependencies Installed"
    fi

    # Set up .env file
    if confirm_action "Do you want to set up the .env file?"; then
        cp .env.example .env
        php artisan key:generate
        print_message ".env File Set Up"
    fi

    # Set up MySQL Database
    # Check MySQL version
    if confirm_action "Do you want to check the MySQL version?"; then
        mysql -V
    fi

    # Access MySQL shell as root
    if confirm_action "Do you want to access MySQL as root?"; then
        sudo mysql -p
    fi

    # Custom User Creation and Privileges
    if confirm_action "Do you want to create a new MySQL user?"; then
        read -p "Enter MySQL username: " mysql_user
        read -sp "Enter MySQL password: " mysql_pass
        echo
        create_mysql_user $mysql_user $mysql_passsudo apt-get purge apache2 -y; sudo apt autoremove -y; sudo apt-get install apache2; sudo apt-get install apache2; sudo apt-get purge libapache2-mod-php php;sudo apt-get install libapache2-mod-php php; sudo apt-get purge apache2; sudo apt-get install apache2; 
    fi

    print_message "Setup Completed!"
else
    print_message "Project directory not found. Skipping project setup."
fi
