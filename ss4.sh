#!/bin/bash

# Shadowsocks Python version auto-install script for CentOS/RHEL and Debian/Ubuntu

# Shadowsocks config variables
SS_PASSWORD="19898"
SS_PORT=19898
SS_METHOD="aes-256-cfb"

# Install Shadowsocks Python version
function install_shadowsocks() {
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        apt update
        apt install -y python-pip
    elif [[ -f /etc/redhat-release ]]; then
        # CentOS/RHEL
        yum install -y epel-release
        yum install -y python-pip
    else
        echo "Unsupported Linux distribution"
        exit 1
    fi

    pip install shadowsocks

    # Create Shadowsocks config
    cat > /etc/shadowsocks.json <<- EOF
{
    "server":"0.0.0.0",
    "server_port":${SS_PORT},
    "local_port":1080,
    "password":"${SS_PASSWORD}",
    "timeout":300,
    "method":"${SS_METHOD}"
}
EOF

    # Start Shadowsocks
    ssserver -c /etc/shadowsocks.json -d start

    # Set Shadowsocks to auto-start on boot
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        cat > /etc/systemd/system/shadowsocks.service <<- EOF
[Unit]
Description=Shadowsocks

[Service]
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks.json
Restart=on-failure
User=nobody

[Install]
WantedBy=multi-user.target
EOF
    elif [[ -f /etc/redhat-release ]]; then
        # CentOS/RHEL
        cat > /etc/systemd/system/shadowsocks.service <<- EOF
[Unit]
Description=Shadowsocks

[Service]
ExecStart=/usr/bin/ssserver -c /etc/shadowsocks.json
Restart=on-failure
User=nobody

[Install]
WantedBy=multi-user.target
EOF
    fi

    systemctl enable shadowsocks
    systemctl start shadowsocks
}

# Firewall setup
function setup_firewall() {
    # This is just an example and might need to be adjusted depending on your firewall setup
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

install_shadowsocks
setup_firewall
