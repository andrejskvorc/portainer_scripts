#!/bin/bash

# Detect system architecture and ask for confirmation
detected_arch=$(uname -m)
if [ "$detected_arch" == "x86_64" ]; then
  system_arch="x64"
elif [ "$detected_arch" == "aarch64" ]; then
  system_arch="arm64"
else
  system_arch=""
fi

if [ -n "$system_arch" ]; then
  read -p "Detected system architecture is $system_arch. Press enter to confirm or type in another architecture (x64 or arm64): " input_arch
  if [ -n "$input_arch" ]; then
    system_arch=$input_arch
  fi
else
  read -p "Could not detect system architecture. Please enter the architecture (x64 or arm64): " system_arch
fi

# Prompt for hostnames
read -p "Enter the hostname for the Ubuntu server (e.g. dc.mydomain.com or .local): " ubuntu_hostname
read -p "Enter the hostname for Portainer (e.g. docker.mydomain.com or .local): " portainer_hostname

# Prompt for network configuration
read -p "Do you want to set a static IP address? (y/n): " set_static_ip
if [ "$set_static_ip" == "y" ]; then
  read -p "Enter the static IP address (e.g. 192.168.1.10): " static_ip
  read -p "Enter the subnet mask (e.g. 255.255.255.0): " subnet_mask
  read -p "Enter the default gateway (e.g. 192.168.1.1): " gateway
  read -p "Enter the DNS server addresses (space-separated, e.g. 8.8.8.8 8.8.4.4): " dns_servers
fi

# Prompt for firewall configuration
read -p "Do you want to open web ports (HTTP/HTTPS)? (y/n): " open_web_ports
read -p "Do you want to open mail ports (SMTP/POP3/IMAP)? (y/n): " open_mail_ports

# Prompt for enabling SSH login for the root user
read -p "Do you want to enable SSH login for the root user? (y/n): " enable_root_ssh

# Update and upgrade packages
# sudo apt update && sudo apt upgrade -y

# Prompt user to choose between Docker CE and EE
read -p "Do you want to install Docker Community Edition (CE) or Enterprise Edition (EE)? (C/E): " docker_edition

# Install Docker CE
if [[ "$docker_edition" =~ ^[Cc]$ ]]; then
  echo "Installing Docker Community Edition..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker EE
elif [[ "$docker_edition" =~ ^[Ee]$ ]]; then
  echo "Installing Docker Enterprise Edition..."
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://packages.docker.com/1.13/install/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb https://packages.docker.com/1.13/apt/repo/ubuntu-$(lsb_release -cs) main"
  sudo apt-get update
  sudo apt-get install -y docker-ee docker-ee-cli containerd.io
fi

# Start and enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Detect filesystem
filesystem=$(df -T / | tail -1 | awk '{print $2}')

if [[ "$filesystem" != "zfs" && "$filesystem" != "btrfs" ]]; then
  read -p "The current filesystem is not ZFS or BTRFS. Do you want to use the devicemapper storage driver? (y/N): " use_devicemapper
  if [[ "$use_devicemapper" =~ ^[Yy]$ ]]; then
    sudo apt-get install -y lvm2 thin-provisioning-tools && echo '{"storage-driver": "devicemapper"}' | sudo tee /etc/docker/daemon.json
  fi
fi

sudo systemctl restart docker

# Prompt for Portainer edition
read -p "Which edition of Portainer do you want to install? (ce or be): " portainer_edition
if [ "$portainer_edition" == "be" ]; then
  read -p "Do you have a Portainer license? (y/n): " has_license
  if [ "$has_license" == "y" ]; then
    read -p "Is the license in a file or will you enter the key as a string? (file/string): " license_type
    if [ "$license_type" == "file" ]; then
      read -p "Enter the full path to the Portainer license file: " license_path
    else
      read -p "Enter the Portainer license key: " license_key
      echo "$license_key" > portainer_license_key.txt
      license_path="./portainer_license_key.txt"
    fi
  fi
fi

# Install Portainer
sudo docker volume create portainer_data
if [ "$portainer_edition" == "be" ] && [ "$has_license" == "y" ]; then
  sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -v $license_path:/license/portainer.lic portainer/portainer-ee
else
  sudo docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
fi

# Clean up sensitive data
if [ "$license_type" == "string" ]; then
  rm -f portainer_license_key.txt
fi

