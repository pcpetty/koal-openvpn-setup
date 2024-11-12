# OpenVPN Installation Guide

# Prerequisites:
# - Arch Linux with root/sudo access.
# - Basic networking knowledge for VPNs, IPs, and interfaces.

# 1. System Update and Dependency Installation
sudo pacman -Syu       # Update system packages
sudo pacman -S openvpn easy-rsa       # Install OpenVPN and Easy-RSA

# Troubleshooting:
# - "Could not resolve host": Check internet/DNS.
# - "Unable to lock database": Use `sudo rm /var/lib/pacman/db.lck`.

# 2. Set Up Public Key Infrastructure (PKI)
mkdir -p ~/openvpn-ca && cd ~/openvpn-ca
easyrsa init-pki       # Initialize PKI
easyrsa build-ca       # Build Certificate Authority (CA)
easyrsa build-server-full server nopass       # Generate Server Certificate and Key
easyrsa gen-dh       # Generate Diffie-Hellman Parameters
easyrsa build-client-full client1 nopass       # Generate Client Certificate

# Troubleshooting:
# - "easy-rsa command not found": Install `easy-rsa`.
# - "Invalid character in CA name": Avoid special characters.

# 3. Configuring the OpenVPN Server
# Copy Certificates and Keys
sudo cp ~/openvpn-ca/pki/ca.crt ~/openvpn-ca/pki/issued/server.crt ~/openvpn-ca/pki/private/server.key ~/openvpn-ca/pki/dh.pem /etc/openvpn/

# Create Server Configuration File
sudo nano /etc/openvpn/server.conf
# Paste below content:
# port 1194
# proto udp
# dev tun
# ca ca.crt
# cert server.crt
# key server.key
# dh dh.pem
# server 10.8.0.0 255.255.255.0
# ifconfig-pool-persist ipp.txt
# keepalive 10 120
# cipher AES-256-CBC
# persist-key
# persist-tun
# user nobody
# group nogroup
# verb 3

# Enable IP Forwarding
sudo sysctl -w net.ipv4.ip_forward=1       # Temporarily enable
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.d/99-sysctl.conf       # Permanent setting

# 4. Configuring Firewall Rules
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route | grep '^default' | awk '{print $5}') -j MASQUERADE       # VPN traffic routing
sudo pacman -S iptables       # Install iptables
sudo iptables-save | sudo tee /etc/iptables/iptables.rules       # Save rules
sudo systemctl enable iptables       # Enable iptables on boot

# Troubleshooting:
# - "iptables command not found": Install `iptables`.
# - "Permission denied": Ensure `sudo` privileges.

# 5. Starting and Enabling OpenVPN Server
sudo systemctl start openvpn@server       # Start OpenVPN server
sudo systemctl enable openvpn@server       # Enable OpenVPN on boot
sudo systemctl status openvpn@server       # Check server status

# Troubleshooting:
# - "Failed to start OpenVPN service": Check server config file. Use `journalctl -xe` for logs.
# - "OpenVPN not found in systemctl": Verify `/etc/openvpn/server.conf`.

# 6. Configure the Client
# Create Client Configuration (client.ovpn):
# Copy `ca.crt`, `client1.crt`, `client1.key` to the client machine and create `client.ovpn` with the following content:
# client
# dev tun
# proto udp
# remote YOUR_SERVER_IP 1194
# resolv-retry infinite
# nobind
# persist-key
# persist-tun
# remote-cert-tls server
# cipher AES-256-CBC
# auth SHA256
# verb 3

# Connect to VPN:
sudo openvpn --config client.ovpn

# Troubleshooting:
# - "Cannot resolve server address": Check IP or try dynamic DNS.
# - "TLS handshake failed": Verify server and client certificates.

# Additional Resources:
# - OpenVPN Documentation: https://openvpn.net/community-resources/
# - Easy-RSA Documentation: https://github.com/OpenVPN/easy-rsa
# - Arch Linux OpenVPN Wiki: https://wiki.archlinux.org/title/OpenVPN
