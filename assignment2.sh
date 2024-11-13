#!/bin/bash

# This script is for our second assignment, System Modification. #

#!/bin/bash

# Define variables
NETPLAN_CONFIG="/etc/netplan/01-netcfg.yaml"
HOSTS_FILE="/etc/hosts"
TARGET_IP="192.168.16.21"
TARGET_NETMASK="24"
TARGET_HOSTNAME="server1"

# Function to update netplan configuration
update_netplan() {
    echo "Updating netplan configuration..."
    if grep -q "$TARGET_IP/$TARGET_NETMASK" "$NETPLAN_CONFIG"; then
        echo "Netplan configuration already set."
    else
        echo "Setting netplan configuration..."
        sudo sed -i "/addresses:/a \ \ \ \ \ \ \ \ - $TARGET_IP/$TARGET_NETMASK" "$NETPLAN_CONFIG"
        sudo netplan apply
        echo "Netplan configuration updated."
    fi
}

# Function to update /etc/hosts
update_hosts() {
    echo "Updating /etc/hosts..."
    if grep -q "$TARGET_IP $TARGET_HOSTNAME" "$HOSTS_FILE"; then
        echo "/etc/hosts already has the correct entry."
    else
        echo "Setting /etc/hosts entry..."
        sudo sed -i "/$TARGET_HOSTNAME/d" "$HOSTS_FILE"
        echo "$TARGET_IP $TARGET_HOSTNAME" | sudo tee -a "$HOSTS_FILE"
        echo "/etc/hosts updated."
    fi
}

# Run the functions
update_netplan
update_hosts

echo "Configuration complete."
