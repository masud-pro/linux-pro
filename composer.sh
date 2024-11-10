#!/bin/bash

# Function to print messages
print_message() {
    echo -e "\e[32m$1\e[0m" # Prints in green text
}

# Check if Composer is already installed
if command -v composer >/dev/null 2>&1; then
    print_message "Composer is already installed. Skipping installation."
else
    # Create directory if it doesn't exist
    mkdir -p ~/.local/bin

    # Download and install Composer
    curl -sS https://getcomposer.org/installer | php

    # Move Composer to the bin directory
    mv composer.phar ~/.local/bin/composer

    # Add Composer to PATH if not already included
    export PATH="$HOME/.local/bin:$PATH"
    print_message "Composer Installed"
fi
