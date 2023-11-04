#!/bin/bash

# Shadowsocks installation script for various Linux distributions

# Define Shadowsocks config variables
SS_PASSWORD="19898"
SS_PORT=19898
SS_METHOD="aes-256-gcm"

# Install Shadowsocks-libev from repository
function install_shadowsocks() {
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        apt update
        apt install -y shadowsocks-libev
    elif [[ -f /etc/redhat-release ]]; then
        # CentOS/Redhat/Fedora
        yum update
        yum install -y epel-release
        yum install -y shadowsocks-libev
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
}

# Configure Shadowsocks
function configure_shadowsocks() {
    # Create Shadowsocks config file
    local ss_config="/etc/shadowsocks-libev/config.json"
    cat > $ss_config <<- EOF
    {
        "server":"0.0.0.0",
        "server_port":${SS_PORT},
        "password":"${SS_PASSWORD}",
        "timeout":300,
        "method":"${SS_METHOD}",
        "fast_open": false,
        "nameserver":"8.8.8.8"
    }
EOF
    # Set permissions for the config file
    chmod 644 $ss_config
}

# Enable and start Shadowsocks service
function start_shadowsocks() {
    systemctl enable shadowsocks-libev
    systemctl start shadowsocks-libev
}

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
else
    install_shadowsocks
    configure_shadowsocks
    start_shadowsocks
    echo "Shadowsocks has been installed and started."
fi
