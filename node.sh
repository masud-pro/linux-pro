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

# Source NVM from nvm.sh
source_nvm() {
    # Check if NVM is installed, if not, install it.
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        source "$HOME/.nvm/nvm.sh"
    else
        echo "NVM is not installed. Please run nvm.sh first."
        exit 1
    fi
}

# Install Node.js using NVM
install_node() {
    local version=$1
    print_message "Installing Node.js version $version"
    source_nvm
    if nvm install "$version"; then
        print_message "Node.js version $version installed"
    else
        echo "Failed to install Node.js version $version"
        exit 1
    fi
}

# Set active version for Node.js
set_active_node_version() {
    local version=$1
    print_message "Setting Node.js version $version as active"
    source_nvm
    if nvm use "$version"; then
        print_message "Node.js version $version is now active."
    else
        print_message "Node.js version $version is not installed. Installing..."
        install_node "$version"
        nvm use "$version"
    fi
}

# Uninstall Node.js
uninstall_node() {
    local version=$1
    print_message "Uninstalling Node.js version $version"
    source_nvm
    nvm uninstall "$version"
    print_message "Node.js version $version removed."
}

# Fetch the last 5 major versions of Node.js
fetch_last_5_major_versions() {
    source_nvm
    local major_versions
    major_versions=$(nvm ls-remote --lts | grep 'Latest LTS' | tail -n 5)
    
    if [ -z "$major_versions" ]; then
        echo "Could not fetch the last 5 major versions."
        exit 1
    fi

    echo "$major_versions"
}

# Parse arguments
FORCE=false
RESET=false
UNINSTALL=false
USE=false
USE_VERSION=""

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
    --use)
        USE=true
        ;;
    --use=*)
        USE=true
        USE_VERSION="${arg#*=}"
        ;;
    esac
done

# Main logic for Node.js
if $RESET; then
    uninstall_node 22
    install_node 22
elif $UNINSTALL; then
    uninstall_node 22
elif $FORCE; then
    uninstall_node 22
    install_node 22
elif $USE; then
    if [[ -n $USE_VERSION ]]; then
        set_active_node_version "$USE_VERSION"
    else
        fetch_last_5_major_versions | while read -r version; do
            echo "$version"
        done
        echo "Please select a version:"
        read -r selected_version
        set_active_node_version "$selected_version"
    fi
else
    # Source NVM and check for Node.js version 22
    source_nvm
    if ! nvm list | grep -q 'v22\.'; then
        if confirm_action "Node.js version 22 is not installed. Do you want to install it?"; then
            install_node 22
        fi
    else
        print_message "Node.js version 22 is already installed."
    fi
    
    # Install the last 5 major versions
    print_message "Installing the last 5 major versions of Node.js..."
    fetch_last_5_major_versions | while read -r version; do
        install_node "$version"
    done
fi
