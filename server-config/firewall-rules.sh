#!/bin/bash

# Configure iptables for VPN traffic routing
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $(ip route | grep '^default' | awk '{print $5}') -j MASQUERADE
echo "Firewall rules configured for VPN traffic routing."
