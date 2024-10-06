#!/usr/bin/env bash

# Exit if any command fails
set -e

# Function to display messages
echo_info() {
  echo -e "\n[INFO] $1\n"
}

# 1. Update the system
echo_info "Updating and upgrading Ubuntu packages..."
sudo apt update && sudo apt upgrade -y

# 2. Configure UFW (Uncomplicated Firewall)
echo_info "Configuring UFW (Uncomplicated Firewall)..."
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh          # Allow SSH (port 22 by default)
sudo ufw allow http         # Allow HTTP (port 80)
sudo ufw allow https        # Allow HTTPS (port 443)
sudo ufw enable             # Enable UFW

# 3. SSH configuration: Disallow root login, enforce SSH key authentication
echo_info "Configuring SSH security..."
# sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config   # Disable root login
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config  # Disable password authentication
sudo sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# 4. Create a new user
# NEW_USER="hosty"   # Replace 'yourusername' with your desired username

# # Check if the user already exists
# if id "$NEW_USER" &>/dev/null; then
#     echo_info "User $NEW_USER already exists."
# else
#     echo_info "Creating a new user $NEW_USER..."
#     sudo adduser --disabled-password --gecos "" $NEW_USER
#     sudo usermod -aG sudo $NEW_USER
# fi

# # 5. Copy SSH keys from root to new user
# echo_info "Copying SSH keys from root to $NEW_USER..."
# sudo mkdir -p /home/$NEW_USER/.ssh
# sudo cp /root/.ssh/authorized_keys /home/$NEW_USER/.ssh/
# sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
# sudo chmod 700 /home/$NEW_USER/.ssh
# sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys

# 6. Install Fail2Ban to protect SSH from brute force attacks
# echo_info "Installing and configuring Fail2Ban..."
# sudo apt install fail2ban -y

# # Create a basic config file for SSH
# cat <<EOL | sudo tee /etc/fail2ban/jail.local
# [sshd]
# enabled = true
# port = ssh
# logpath = %(sshd_log)s
# maxretry = 5
# bantime = 3600
# EOL

# sudo systemctl enable fail2ban
# sudo systemctl start fail2ban

# 7. (Optional) Disable IPv6 if you are not using it
# echo_info "Disabling IPv6..."
# sudo sed -i 's/#net.ipv6.conf.all.disable_ipv6 = 1/net.ipv6.conf.all.disable_ipv6 = 1/' /etc/sysctl.conf
# sudo sed -i 's/#net.ipv6.conf.default.disable_ipv6 = 1/net.ipv6.conf.default.disable_ipv6 = 1/' /etc/sysctl.conf
# sudo sysctl -p

# 8. Install security updates automatically
echo_info "Setting up unattended security updates..."
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

echo_info "Security setup complete. Your VPS is now more secure!"

# sudo su - $NEW_USER