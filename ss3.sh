#!/bin/bash

# Shadowsocks-libev auto-installation script for CentOS/RHEL and Debian/Ubuntu
# This script will compile and install shadowsocks-libev from source

# Shadowsocks config variables
SS_PASSWORD="19898"
SS_PORT=19898
SS_METHOD="aes-256-gcm"

# Install required packages
function install_packages() {
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        apt update
        apt install -y --no-install-recommends build-essential autoconf libtool libssl-dev gawk debhelper dh-systemd \
        init-system-helpers pkg-config asciidoc xmlto apg libpcre3-dev zlib1g-dev libev-dev libudns-dev libsodium-dev \
        libc-ares-dev automake git
    elif [[ -f /etc/redhat-release ]]; then
        # CentOS/RHEL
        yum groupinstall 'Development Tools' -y
        yum install epel-release -y
        yum install -y git libev-devel c-ares-devel libev-devel zlib-devel openssl-devel asciidoc xmlto
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi
}

# Compile and install Shadowsocks from source
function compile_shadowsocks() {
    git clone https://github.com/shadowsocks/shadowsocks-libev.git
    cd shadowsocks-libev
    git submodule update --init --recursive
    ./autogen.sh && ./configure && make
    make install
}

# Configure Shadowsocks
function configure_shadowsocks() {
    mkdir -p /etc/shadowsocks-libev
    local ss_config="/etc/shadowsocks-libev/config.json"
    cat > $ss_config <<- EOF
{
    "server":"0.0.0.0",
    "server_port":${SS_PORT},
    "password":"${SS_PASSWORD}",
    "timeout":300,
    "method":"${SS_METHOD}",
    "fast_open":false,
    "mode":"tcp_and_udp",
    "nameserver":"8.8.8.8"
}
EOF
}

# Setup Shadowsocks-libev service
function setup_service() {
    local service_file="/etc/systemd/system/shadowsocks-libev.service"
    cat > $service_file <<- EOF
[Unit]
Description=Shadowsocks-libev Default Server Service
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=32768
ExecStart=/usr/local/bin/ss-server -c /etc/shadowsocks-libev/config.json

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable shadowsocks-libev
    systemctl start shadowsocks-libev
}

# Setup firewall rules
function setup_firewall() {
    if command -v ufw >/dev/null; then
        ufw allow ${SS_PORT}/tcp
        ufw allow ${SS_PORT}/udp
        ufw reload
    elif command -v firewall-cmd >/dev/null; then
        firewall-cmd --permanent --add-port=${SS_PORT}/tcp
        firewall-cmd --permanent --add-port=${SS_PORT}/udp
        firewall-cmd --reload
    else
        echo "Firewall not found. Please manually open the ports if necessary."
    fi
}

# Start the installation process
function start_installation() {
    install_packages
    compile_shadowsocks
    configure_shadowsocks
    setup_service
    setup_firewall
    echo "Shadowsocks-libev installation completed."
}

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
else
    start_installation
fi
