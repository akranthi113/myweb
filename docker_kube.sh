#!/bin/bash

# This script installs Docker and Kubernetes on a CentOS/RHEL system

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to check command success
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    else
        echo "Completed: $1"
    fi
}

# Docker setup

echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    yum install docker -y
    check_command "Install Docker"
else
    echo "Docker is already installed."
fi

echo "Starting and enabling Docker service..."
systemctl enable docker
systemctl start docker
check_command "Start Docker service"

echo "Configuring Docker daemon..."
if [ ! -f /etc/docker/daemon.json ]; then
    cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
    check_command "Configure Docker daemon"
else
    echo "Docker daemon is already configured."
fi

echo "Restarting Docker service..."
systemctl restart docker
check_command "Restart Docker service"

echo "Docker installation and configuration completed."

# Kubernetes setup

echo "Checking if Kubernetes components are installed..."
if ! rpm -q kubelet kubeadm kubectl &> /dev/null; then
    echo "Adding Kubernetes repository configuration..."
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF
    check_command "Add Kubernetes repository configuration"

    echo "Installing Kubernetes components..."
    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
    check_command "Install Kubernetes components"
else
    echo "Kubernetes components are already installed."
fi

echo "Configuring sysctl settings for Kubernetes..."
if [ ! -f /etc/sysctl.d/k8s.conf ]; then
    cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
    sysctl --system
    check_command "Configure sysctl settings for Kubernetes"
else
    echo "Sysctl settings for Kubernetes are already configured."
fi

echo "Temporarily disabling SELinux..."
if [ $(getenforce) != "Disabled" ]; then
    setenforce 0
    check_command "Disable SELinux"
else
    echo "SELinux is already disabled."
fi

echo "Turn off swap..."
if [ $(swapon -s | wc -l) -gt 1 ]; then
    swapoff -a
    check_command "Turn off swap"
else
    echo "Swap is already turned off."
fi

echo "Starting and enabling kubelet service..."
systemctl enable kubelet
systemctl start kubelet
check_command "Start kubelet service"

echo "Setup completed."
