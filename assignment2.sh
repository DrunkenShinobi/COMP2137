#!/bin/bash

# This script is for our second assignment, System Modification. #

#!/bin/bash

# Define those variables #
netplanApply="/etc/netplan/01-netcfg.yaml"
hostsFile="/etc/hosts"
targetIP="192.168.16.21"
targetNetMask="24"
hostName="server1"

# Function to update netplan configuration
update_netplan() {
    echo "Updating netplan configuration..."
    if grep -q "$targetIP/$targetNetMask" "$netplanApply"; then
        echo "Netplan configuration already set."
    else
        echo "Applying new netplan configuration..."
        sudo sed -i "/addresses:/a \ \ \ \ \ \ \ \ - $targetIP/$targetNetMask" "$netplanApply"
        sudo netplan apply
        echo "Netplan configuration has been updated."
    fi
}

# Function to update /etc/hosts
update_hosts() {
    echo "Updating /etc/hosts..."
    if grep -q "$targetIP $hostName" "$hostsFile"; then
        echo "/etc/hosts already has the correct information."
    else
        echo "Setting the /etc/hosts entry..."
        sudo sed -i "/$hostName/d" "$hostsFile"
        echo "$targetIP $hostName" | sudo tee -a "$hostsFile"
        echo "/etc/hosts has been updated."
    fi
}

# Run the functions
update_netplan
update_hosts

echo "Configuration complete!"
