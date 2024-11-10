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

# Main script starts here

# Update packages
if confirm_action "Do you want to update system packages?"; then
    print_message "Updating Packages"
    sudo apt update && sudo apt upgrade -y
    print_message "Packages Updated"
fi

# Install core dependencies
# if confirm_action "Do you want to install core dependencies (curl, wget, git, etc.)?"; then
#     print_message "Installing Core Dependencies"
#     sudo apt install -y curl wget git unzip build-essential software-properties-common
#     print_message "Core Dependencies Installed"
# fi




### Install Composer
if ! command -v composer &>/dev/null; then
    if confirm_action "Composer is not installed. Do you want to install Composer?"; then
        print_message "Installing Composer"
        source ./composer.sh
    fi
else
    print_message "Composer is already installed, skipping."
fi
