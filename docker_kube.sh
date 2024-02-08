#!/bin/bash

# This script installs Docker and Kubernetes on a CentOS/RHEL system

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Docker setup

# Install Docker using yum package manager
echo "Installing Docker..."
yum install docker -y
if [ $? -ne 0 ]; then
    echo "Failed to install Docker. Aborting."
    exit 1
fi

# Start and enable the Docker service
echo "Starting and enabling Docker service..."
systemctl enable docker
systemctl start docker
if [ $? -ne 0 ]; then
    echo "Failed to start Docker service. Aborting."
    exit 1
fi

# Configure Docker daemon with a specific cgroup driver
echo "Configuring Docker daemon..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
if [ $? -ne 0 ]; then
    echo "Failed to configure Docker daemon. Aborting."
    exit 1
fi

# Restart Docker service to apply configuration changes
echo "Restarting Docker service..."
systemctl restart docker
if [ $? -ne 0 ]; then
    echo "Failed to restart Docker service. Aborting."
    exit 1
fi

echo "Docker installation and configuration completed."

# Kubernetes setup

# Add Kubernetes repository configuration
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
if [ $? -ne 0 ]; then
    echo "Failed to add Kubernetes repository configuration. Aborting."
    exit 1
fi

# Configure sysctl settings for Kubernetes
echo "Configuring sysctl settings for Kubernetes..."
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
if [ $? -ne 0 ]; then
    echo "Failed to configure sysctl settings for Kubernetes. Aborting."
    exit 1
fi

# Apply sysctl settings
echo "Applying sysctl settings..."
sysctl --system
if [ $? -ne 0 ]; then
    echo "Failed to apply sysctl settings. Aborting."
    exit 1
fi

# Temporarily disable SELinux
echo "Disabling SELinux..."
setenforce 0
if [ $? -ne 0 ]; then
    echo "Failed to disable SELinux. Aborting."
    exit 1
fi

# Turn off swap
echo "Turning off swap..."
swapoff -a
if [ $? -ne 0 ]; then
    echo "Failed to turn off swap. Aborting."
    exit 1
fi

# Install Kubernetes components
echo "Installing Kubernetes components..."
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
if [ $? -ne 0 ]; then
    echo "Failed to install Kubernetes components. Aborting."
    exit 1
fi

# Start and enable kubelet service
echo "Starting and enabling kubelet service..."
systemctl enable kubelet
systemctl start kubelet
if [ $? -ne 0 ]; then
    echo "Failed to start kubelet service. Aborting."
    exit 1
fi

echo "Kubernetes setup completed."

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
echo "Exporting KUBECONFIG for current session..."
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Setup completed."
