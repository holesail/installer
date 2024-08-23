#!/bin/bash

# GitHub repository details
REPO="holesail/holesail"
INSTALL_DIR="$HOME/.holesail"
BIN_PATH="$INSTALL_DIR/holesail"

# Function to detect OS and architecture
detect_os_arch() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi

    if [[ "$(uname -m)" == "x86_64" ]]; then
        ARCH="x64"
    elif [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; then
        ARCH="arm64"
    else
        echo "Unsupported architecture: $(uname -m)"
        exit 1
    fi
}

# Function to fetch the latest release tag from GitHub
fetch_latest_release() {
    echo "Fetching the latest release from GitHub..."
    LATEST_TAG=$(curl --silent "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$LATEST_TAG" ]; then
        echo "Failed to fetch the latest release. Exiting."
        exit 1
    fi
    echo "Latest release: $LATEST_TAG"
}

# Function to download and install Holesail
install_holesail() {
    detect_os_arch
    fetch_latest_release

    # Construct download URL based on OS and architecture
    FILE_NAME="holesail-$OS-$ARCH-unsigned"
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$FILE_NAME"

    # Create installation directory if it doesn't exist
    mkdir -p $INSTALL_DIR

    # Download the executable
    echo "Downloading Holesail $LATEST_TAG for $OS $ARCH..."
    curl -L $DOWNLOAD_URL -o $BIN_PATH

    if [ $? -ne 0 ]; then
        echo "Failed to download Holesail. Please check the version and try again."
        exit 1
    fi

    # Make the binary executable for Linux/macOS
    chmod +x $BIN_PATH

    # Add Holesail to the PATH in the user's shell configuration
    SHELL_CONFIG_FILE="$HOME/.bashrc"
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG_FILE="$HOME/.zshrc"
    fi

    if ! grep -q 'export PATH="$HOME/.holesail:$PATH"' $SHELL_CONFIG_FILE; then
        echo 'export PATH="$HOME/.holesail:$PATH"' >> $SHELL_CONFIG_FILE
        echo "Holesail path added to $SHELL_CONFIG_FILE"
    fi

    # Source the shell configuration file to update PATH
    source $SHELL_CONFIG_FILE

    echo "Holesail version $LATEST_TAG installed successfully!"
}

# Function to check if Holesail is installed
check_holesail_installed() {
    if [ -f "$BIN_PATH" ]; then

        CURRENT_VERSION=$($BIN_PATH --version 2>/dev/null)
        if [ "$CURRENT_VERSION" == "$LATEST_TAG" ]; then
            echo "Holesail is up-to-date (version $CURRENT_VERSION)."
            exit 0
        else
            echo "Holesail is installed but outdated (current version: $CURRENT_VERSION)."
            read -p "Do you want to update to version $LATEST_TAG? (y/n): " RESPONSE
            if [[ "$RESPONSE" == "y" ]]; then
                install_holesail
            else
                echo "Update aborted."
                exit 0
            fi
        fi
    else
        echo "Holesail is not installed."
        install_holesail
    fi
}

# Main script logic
check_holesail_installed

