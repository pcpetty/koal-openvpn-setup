#!/bin/bash

# easy-rsa-setup.sh
# A script to set up Easy-RSA for OpenVPN on an Arch Linux server.
# This script initializes the PKI, creates a CA, and generates server and client certificates.

# Set up directories and variables
EASY_RSA_DIR=~/easy-rsa
PKI_DIR=~/openvpn-ca/pki
OUTPUT_DIR=/etc/openvpn

# Install Easy-RSA if not installed
if ! command -v easyrsa &> /dev/null; then
    echo "Easy-RSA is not installed. Installing Easy-RSA..."
    sudo pacman -S easy-rsa --noconfirm
fi

# Create Easy-RSA directory and initialize PKI
echo "Setting up Easy-RSA directory and initializing PKI..."
mkdir -p $EASY_RSA_DIR
cp -r /usr/share/easy-rsa/* $EASY_RSA_DIR
cd $EASY_RSA_DIR
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

# Generate the TLS key for added security (optional, for tls-auth)
echo "Generating TLS key for additional security..."
openvpn --genkey --secret ta.key

# Generate a Client Certificate and Key (you can repeat this for additional clients)
CLIENT_NAME=client1
echo "Generating client certificate and key for $CLIENT_NAME..."
./easyrsa build-client-full $CLIENT_NAME nopass

# Copy all certificates and keys to the OpenVPN directory
echo "Copying certificates and keys to $OUTPUT_DIR..."
sudo mkdir -p $OUTPUT_DIR
sudo cp pki/ca.crt pki/private/server.key pki/issued/server.crt pki/dh.pem ta.key $OUTPUT_DIR
sudo cp pki/issued/${CLIENT_NAME}.crt pki/private/${CLIENT_NAME}.key $OUTPUT_DIR

# Display success message
echo "Easy-RSA setup completed successfully. Certificates and keys are stored in $OUTPUT_DIR."

# Summary of generated files
echo "Generated Files:"
echo "CA Certificate: ca.crt"
echo "Server Certificate: server.crt"
echo "Server Key: server.key"
echo "Diffie-Hellman Parameters: dh.pem"
echo "TLS Key (optional): ta.key"
echo "Client Certificate for $CLIENT_NAME: ${CLIENT_NAME}.crt"
echo "Client Key for $CLIENT_NAME: ${CLIENT_NAME}.key"

# Cleanup
echo "Setup complete. You can now configure OpenVPN with these files."
