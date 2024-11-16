#!/bin/bash

# Utility function to print messages
print_message() {
    echo -e "\e[1;32m$1\e[0m"
}

# Install NVM (Node Version Manager)
install_nvm() {
    print_message "Installing NVM (Node Version Manager)"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

    # Source NVM in the current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Load NVM
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash_completion

    print_message "NVM Installed and Sourced"
}

# Check if NVM is installed
check_nvm() {
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        echo "NVM is installed."
        return 0
    else
        echo "NVM is not installed."
        return 1
    fi
}

# Main logic for NVM
if ! check_nvm; then
    install_nvm
else
    print_message "NVM is already installed."
fi
