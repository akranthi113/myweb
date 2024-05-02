#!/bin/bash

# Function to check for command existence and install if missing
check_and_install() {
  if ! command -v "$1" &> /dev/null; then
    echo "Installing missing command: $1"
    apt install -y "$1"
  fi
}

# Check for required commands and install if missing
check_and_install apt
check_and_install lsb_release

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update packages and install prerequisites
sudo apt update && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl gnupg2

# Create required directories
sudo mkdir -p /usr/share/keyrings/
sudo mkdir -p /etc/apt/sources.list.d/

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group (optional)
sudo usermod -aG docker $USER

# Install Kubernetes components
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize the master node (adjust pod network CIDR if needed)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for current user 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel network plugin (adjust if using a different plugin)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "**Master node initialization complete. Please note the kubeadm join command for worker nodes.**"
