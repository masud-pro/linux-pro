#!/bin/bash

# Function to print messages in green and log them with timestamps
print_message() {
    message="$1"
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")  # Timestamp for each log entry
    echo -e "$timestamp - $message"
    echo "$timestamp - $message" >> "$LOG_FILE"
}

# Log directory and filename based on current date
LOG_DIR="log"
LOG_FILE="$LOG_DIR/composer_$(date +"%Y-%m-%d").log"

# Check if --force parameter is passed
FORCE_INSTALL=false
if [[ "$1" == "--force" ]]; then
    FORCE_INSTALL=true
fi

# Ensure log directory exists
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    print_message "Log directory created at $LOG_DIR."
fi

# Check if PHP is installed
if ! command -v php >/dev/null 2>&1; then
    print_message "PHP is not installed. Please install PHP to proceed with Composer installation."
    exit 1
else
    php_version=$(php -v | head -n 1)
    print_message "PHP is installed. Version: $php_version"
fi

# Check if Composer is already installed
if command -v composer >/dev/null 2>&1; then
    # Get the current Composer version
    current_version=$(composer --version | awk '{print $3}')
    
    if $FORCE_INSTALL; then
        print_message "Force installation requested. Removing current Composer version $current_version..."
        
        # Attempt to uninstall current Composer
        rm -f "$HOME/.local/bin/composer" >> $LOG_FILE 2>&1
        
        if command -v composer >/dev/null 2>&1; then
            sudo rm -f "$(command -v composer)" >> $LOG_FILE 2>&1
        fi

        print_message "Composer uninstalled successfully."
    else
        print_message "Composer is already installed. Version $current_version is installed."
        exit 0
    fi
else
    print_message "Composer not found. Starting installation..."
fi

# Install Composer
print_message "Starting Composer installation..."

# Check if the directory ~/.local/bin/ exists
if [ ! -d "$HOME/.local/bin" ]; then
    print_message "Creating ~/.local/bin directory."
    mkdir -p "$HOME/.local/bin"
fi

# Download Composer installer
curl -sS https://getcomposer.org/installer | php >> $LOG_FILE 2>&1
print_message "Downloaded Composer installer."

# Check if composer.phar was successfully downloaded
if [ -f "composer.phar" ]; then
    # Attempt to move composer.phar to ~/.local/bin/composer
    if mv composer.phar "$HOME/.local/bin/composer" >> $LOG_FILE 2>&1; then
        print_message "Composer installed in ~/.local/bin."
    else
        print_message "Moving composer requires elevated permissions."
        sudo mv composer.phar "$HOME/.local/bin/composer" >> $LOG_FILE 2>&1
        print_message "Composer installed in ~/.local/bin with sudo."
    fi

    # Add Composer to PATH if not already included
    export PATH="$HOME/.local/bin:$PATH"

    # Source the profile file to make Composer available in the current session
    if [[ "$SHELL" == */zsh ]]; then
        source ~/.zshrc
        print_message "Sourced ~/.zshrc."
    elif [[ "$SHELL" == */bash ]]; then
        source ~/.bashrc
        print_message "Sourced ~/.bashrc."
    fi

    # Display the installed Composer version
    installed_version=$(composer --version | awk '{print $3}')
    print_message "Composer installation complete. Version $installed_version installed."
else
    print_message "Composer installation failed. Please check your connection or try again."
fi
