#!/bin/bash

# Function to print messages in green
print_message() {
    echo -e "\e[32m$1\e[0m"
}

# Check if Composer is already installed
if command -v composer >/dev/null 2>&1; then
    # If Composer is already installed, get the current version
    current_version=$(composer --version | awk '{print $3}')
    print_message "Composer is already installed. Version $current_version is installed."
else
    # Check if the directory ~/.local/bin/ exists
    if [ ! -d "$HOME/.local/bin" ]; then
        print_message "Creating ~/.local/bin directory."
        mkdir -p "$HOME/.local/bin"
    fi

    # Download Composer installer
    curl -sS https://getcomposer.org/installer | php

    # Check if composer.phar was successfully downloaded
    if [ -f "composer.phar" ]; then
        # Attempt to move composer.phar to ~/.local/bin/composer
        if mv composer.phar "$HOME/.local/bin/composer" 2>/dev/null; then
            print_message "Composer installed in ~/.local/bin."
        else
            print_message "Moving composer requires elevated permissions."
            sudo mv composer.phar "$HOME/.local/bin/composer"
            print_message "Composer installed in ~/.local/bin with sudo."
        fi

        # Add Composer to PATH if not already included
        export PATH="$HOME/.local/bin:$PATH"

        # Source the profile file to make Composer available in the current session
        if [[ "$SHELL" == */zsh ]]; then
            source ~/.zshrc
        elif [[ "$SHELL" == */bash ]]; then
            source ~/.bashrc
        fi

        # Display the installed Composer version
        installed_version=$(composer --version | awk '{print $3}')
        print_message "Composer installation complete. Version $installed_version installed."
    else
        print_message "Composer installation failed. Please check your connection or try again."
    fi
fi
