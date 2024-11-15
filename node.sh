#!/bin/bash

# Utility function to print messages
print_message() {
    echo -e "\e[1;32m$1\e[0m"
}

# Confirm action with default 'yes'
confirm_action() {
    local prompt="${1} [Y/n]: "
    read -r -p "$prompt" response
    response=${response,,} # Convert to lowercase
    [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]]
}

# Check if a package is installed and fetch version
check_package() {
    local package=$1
    if command -v "$package" &>/dev/null; then
        version=$("$package" --version 2>/dev/null || "$package" -v 2>/dev/null)
        echo "$package is installed. Version: $version"
        return 0
    else
        echo "$package is not installed."
        return 1
    fi
}

# Install NVM
install_nvm() {
    print_message "Installing NVM (Node Version Manager)"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # Load NVM
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load NVM bash_completion
    print_message "NVM Installed"
}

# Install Node.js using NVM
install_node() {
    local version=$1
    if nvm install "$version"; then
        print_message "Node.js version $version Installed"
    else
        echo "Failed to install Node.js version $version"
        exit 1
    fi
}

# Install Yarn
install_yarn() {
    if confirm_action "Do you want to install Yarn?"; then
        if npm install -g yarn; then
            print_message "Yarn Installed"
        else
            echo "Failed to install Yarn"
            exit 1
        fi
    fi
}

# Uninstall a package completely
uninstall_package() {
    local package=$1
    print_message "Uninstalling $package"
    case $package in
    nvm)
        rm -rf "$HOME/.nvm"
        sed -i '/nvm.sh/d' ~/.bashrc ~/.zshrc
        sed -i '/NVM_DIR/d' ~/.bashrc ~/.zshrc
        ;;
    node)
        nvm uninstall "$2" # Pass Node.js version if needed
        ;;
    yarn)
        npm uninstall -g yarn
        ;;
    *)
        echo "Unsupported package for uninstallation"
        ;;
    esac
    print_message "$package and all related data removed."
}

# Parse arguments
FORCE=false
RESET=false
UNINSTALL=false

for arg in "$@"; do
    case $arg in
    --force)
        FORCE=true
        ;;
    --reset)
        RESET=true
        ;;
    --uninstall)
        UNINSTALL=true
        ;;
    esac
done

# Main logic
if $RESET; then
    uninstall_package nvm
    uninstall_package yarn
    install_nvm
    if confirm_action "Do you want to install Node.js version 22 using NVM?"; then
        install_node 22
    fi
    install_yarn
elif $UNINSTALL; then
    uninstall_package nvm
    uninstall_package yarn
elif ! check_package nvm; then
    if confirm_action "NVM (Node Version Manager) is not installed. Do you want to install NVM and Node.js?"; then
        install_nvm
        if confirm_action "Do you want to install Node.js version 22 using NVM?"; then
            install_node 22
        fi
        install_yarn
    fi
elif $FORCE; then
    uninstall_package nvm
    uninstall_package yarn
    install_nvm
    if confirm_action "Do you want to install Node.js version 22 using NVM?"; then
        install_node 22
    fi
    install_yarn
else
    print_message "NVM is already installed, skipping."

    # Check Node.js version
    if ! nvm list | grep -q 'v22\.'; then
        if confirm_action "Node.js version 22 is not installed. Do you want to install it?"; then
            install_node 22
        fi
    else
        print_message "Node.js version 22 is already installed, skipping."
    fi

    # Check Yarn
    if ! check_package yarn; then
        install_yarn
    else
        print_message "Yarn is already installed, skipping."
    fi
fi
