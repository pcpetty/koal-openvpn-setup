#!/bin/bash

# install-openvpn.sh
# Script to install OpenVPN and set up server configuration on Arch Linux.

# Update system and install OpenVPN and Easy-RSA
echo "Updating system and installing OpenVPN and Easy-RSA..."
sudo pacman -Syu --noconfirm
sudo pacman -S openvpn easy-rsa iptables --noconfirm

# Set up directories for Easy-RSA and PKI
EASY_RSA_DIR=~/easy-rsa
OUTPUT_DIR=/etc/openvpn
echo "Setting up Easy-RSA directories..."
mkdir -p $EASY_RSA_DIR
cp -r /usr/share/easy-rsa/* $EASY_RSA_DIR
cd $EASY_RSA_DIR

# Initialize the PKI
echo "Initializing PKI..."
./easyrsa init-pki

# Build the CA (Certificate Authority)
echo "Building the Certificate Authority (CA)..."
./easyrsa build-ca nopass

# Generate the Server Certificate and Key
echo "Generating the server certificate and key..."
./easyrsa build-server-full server nopass

# Generate Diffie-Hellman parameters
echo "Generating Diffie-Hellman parameters..."
./easyrsa gen-dh

# Generate the TLS key for additional security
echo "Generating TLS key for additional security..."
openvpn --genkey --secret ta.key

# Generate a Client Certificate and Key (you can repeat this for additional clients)
CLIENT_NAME=client1
echo "Generating client certificate and key for $CLIENT_NAME..."
./easyrsa build-client-full $CLIENT_NAME nopass

# Create OpenVPN server configuration file
echo "Creating OpenVPN server configuration file..."
sudo tee $OUTPUT_DIR/server.conf > /dev/null <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
tls-auth ta.key 0
cipher AES-256-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log-append /var/log/openvpn.log
verb 3
EOF

# Copy all certificates and keys to the OpenVPN directory
echo "Copying certificates and keys to $OUTPUT_DIR..."
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key $OUTPUT_DIR
sudo cp pki/issued/${CLIENT_NAME}.crt pki/private/${CLIENT_NAME}.key $OUTPUT_DIR

# Set up firewall rules for OpenVPN
echo "Configuring firewall rules for OpenVPN..."
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route | grep '^default' | awk '{print $5}') -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/iptables.rules
sudo systemctl enable iptables

# Enable and start OpenVPN server
echo "Starting and enabling OpenVPN server..."
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

# Display success message
echo "OpenVPN installation and configuration completed successfully."
echo "Server is running and configured with default settings."
