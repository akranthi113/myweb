#!/bin/bash

# Function to check for command existence and install if missing
check_and_install() {
  if ! command -v "$1" &> /dev/null; then
    echo "Installing missing command: $1"
    dnf install -y "$1"
  fi
}

# Check for required commands and install if missing
check_and_install dnf
check_and_install lsb_release

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update packages and install prerequisites
sudo dnf update -y
sudo dnf install -y dnf-utils device-mapper-persistent-data lvm2

# Install Docker
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker $USER

# Create required directories
sudo mkdir -p /usr/share/keyrings/
sudo mkdir -p /etc/yum.repos.d/

# Install Kubernetes components
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# Initialize the master node (adjust pod network CIDR if needed)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for current user 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel network plugin (adjust if using a different plugin)
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "**Master node initialization complete. Please note the kubeadm join command for worker nodes.**"
