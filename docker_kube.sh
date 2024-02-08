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

echo "Installing Docker..."
yum install docker -y
check_command "Install Docker"

echo "Starting and enabling Docker service..."
systemctl enable docker
systemctl start docker
check_command "Start Docker service"

echo "Configuring Docker daemon..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
check_command "Configure Docker daemon"

echo "Restarting Docker service..."
systemctl restart docker
check_command "Restart Docker service"

echo "Docker installation and configuration completed."

# Kubernetes setup

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

echo "Configuring sysctl settings for Kubernetes..."
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
check_command "Configure sysctl settings for Kubernetes"

echo "Temporarily disable SELinux..."
setenforce 0
check_command "Disable SELinux"

echo "Turn off swap..."
swapoff -a
check_command "Turn off swap"

echo "Installing Kubernetes components..."
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
check_command "Install Kubernetes components"

echo "Starting and enabling kubelet service..."
systemctl enable kubelet
systemctl start kubelet
check_command "Start kubelet service"

# Add kubeconfig to .bash_profile
echo "Adding kubeconfig to .bash_profile..."
if grep -q "export KUBECONFIG=/etc/kubernetes/admin.conf" ~/.bash_profile; then
    echo "The command is already present in .bash_profile."
else
    # Add the command to .bash_profile using vi editor
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
    echo "Command added to .bash_profile."
fi

# Export KUBECONFIG for current session
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Setup completed."
