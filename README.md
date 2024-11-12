```markdown

```bash
koal-openvpn-setup
│
├── README.md                 # Main documentation
├── LICENSE                   # Project license
├── server-config
│   ├── server.conf           # OpenVPN server configuration
│   └── firewall-rules.sh     # Firewall rules script
├── client-config
│   ├── client.ovpn           # Sample client configuration
│   └── easy-rsa-setup.sh     # Script to set up PKI using Easy-RSA
├── scripts
│   ├── install-openvpn.sh    # Full installation and configuration script
│   ├── check-status.sh       # Script to check OpenVPN server status
│   └── memory-update.sh      # Memory status update script
└── docs
    ├── INSTALLATION.md       # Detailed installation guide
    └── SECURITY.md           # Security considerations and tips

```
```


```markdown
# OpenVPN Setup Guide on Arch Linux with KDE Plasma

## Overview
This project provides a complete guide to setting up an OpenVPN server on Arch Linux. It covers installation, configuration, and firewall setup, and includes scripts to simplify the process. This setup is tailored for Arch Linux with KDE Plasma.

## Features
- Automated installation and configuration scripts.
- Secure server and client setup using Easy-RSA.
- Configurable firewall rules for enhanced security.
- Real-time server status check scripts.

## Project Structure
- **server-config**: Configuration files for the OpenVPN server.
- **client-config**: Client configuration files and setup scripts.
- **scripts**: Utility scripts for installation, configuration, and status monitoring.
- **docs**: Additional resources covering installation and security.

## Requirements
- Arch Linux (Plasma KDE)
- Basic knowledge of networking and VPNs

## Getting Started

### Installation

1. Clone the repository:

```bash
   git clone https://github.com/pcpetty/koal-openvpn-setup.git
   cd koal-openvpn-setup
```
```
```markdown
2. Run the installation script:

sudo bash scripts/install-openvpn.sh

```

```markdown

For VPN security practices, see SECURITY.md.


### 3.

#### **install-openvpn.sh** (Automated Setup Script)

```bash
#!/bin/bash

# Update and install OpenVPN and Easy-RSA
sudo pacman -Syu
sudo pacman -S openvpn easy-rsa

# Create necessary directories
mkdir -p ~/openvpn-ca && cd ~/openvpn-ca

# Initialize PKI and build server/client certificates
easyrsa init-pki
easyrsa build-ca nopass
easyrsa build-server-full server nopass
easyrsa gen-dh
easyrsa build-client-full client1 nopass

# Move generated files to /etc/openvpn/server
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt /etc/openvpn/
sudo cp pki/dh.pem /etc/openvpn/

# Configure the OpenVPN server
sudo cp ../server-config/server.conf /etc/openvpn/server.conf

# Enable and start the OpenVPN server
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server

echo "OpenVPN installed and server started."
```

```



