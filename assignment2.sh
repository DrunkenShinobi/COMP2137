#!/bin/bash

# Define those variables #
netplanConfig="/etc/netplan/01-netcfg.yaml"
hostsFile="/etc/hosts"
targetIP="192.168.16.21"
targetSubnet="24"
targetHostname="server1"
users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")
dennisSSHKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm"

# Function to update netplan configuration #
update_netplan() {
    echo "Updating netplan configuration..."
    if grep -q "$targetIP/$targetSubnet
" "$netplanConfig"; then
        echo "Netplan configuration already set..."
    else
        echo "Setting your new netplan configuration..."
        sudo sed -i "/addresses:/a \ \ \ \ \ \ \ \ - $targetIP/$targetSubnet
    " "$netplanConfig"
        sudo netplan apply
        echo "Netplan configuration has been updated!"
    fi
}

# Function to update /etc/hosts #
update_hosts() {
    echo "Updating /etc/hosts..."
    if grep -q "$targetIP $targetHostname" "$hostsFile"; then
        echo "It seems like /etc/hosts already has the correct entry, no need to update."
    else
        echo "Setting the new /etc/hosts entry..."
        sudo sed -i "/$targetHostname/d" "$hostsFile"
        echo "$targetIP $targetHostname" | sudo tee -a "$hostsFile"
        echo "/etc/hosts has been updated!"
    fi
}

# Function to install Apache2 #
install_apache2() {
    echo "Installing Apache2..."
    if ! dpkg -l | grep -q apache2; then
        sudo apt-get update
        sudo apt-get install -y apache2
        sudo systemctl enable apache2
        sudo systemctl start apache2
        echo "Apache2 has been installed and is now running."
    else
        echo "Hmm, it seems like Apache2 is already installed."
    fi
}

# Function to install Squid #
install_squid() {
    echo "Installing Squid..."
    if ! dpkg -l | grep -q squid; then
        sudo apt-get update
        sudo apt-get install -y squid
        sudo systemctl enable squid
        sudo systemctl start squid
        echo "Squid has been installed and is now running!"
    else
        echo "Hmm, it seems like Squid is already installed."
    fi
}

# Function to create user accounts #
create_users() {
    for user in "${users[@]}"; do
        echo "Creating new user $user..."
        if id "$user" &>/dev/null; then
            echo "User $user already exists!"
        else
            sudo useradd -m -s /bin/bash "$user"
            echo "New user $user has been created!"
        fi

        # Generate SSH keys if they are not already present #
        sudo -u "$user" ssh-keygen -t rsa -b 2048 -f "/home/$user/.ssh/id_rsa" -N "" &>/dev/null
        sudo -u "$user" ssh-keygen -t ed25519 -f "/home/$user/.ssh/id_ed25519" -N "" &>/dev/null

        # Add public keys to authorized_keys as needed #
        cat "/home/$user/.ssh/id_rsa.pub" | sudo tee -a "/home/$user/.ssh/authorized_keys" &>/dev/null
        cat "/home/$user/.ssh/id_ed25519.pub" | sudo tee -a "/home/$user/.ssh/authorized_keys" &>/dev/null

        # Special case for user dennis #
        if [ "$user" == "dennis" ]; then
            echo "$dennisSSHKey" | sudo tee -a "/home/$user/.ssh/authorized_keys" &>/dev/null
            sudo usermod -aG sudo "$user"
        fi

        echo "User $user configured with SSH keys."
    done
}

# Run the functions #
update_netplan
update_hosts
install_apache2
install_squid
create_users

echo "Woohoo! Configuration completed!"
