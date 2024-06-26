#!/bin/bash

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Docker setup

# Install Docker using yum package manager
echo "Installing Docker..."
yum install docker -y

# Start and enable the Docker service
echo "Starting and enabling Docker service..."
systemctl enable docker
systemctl start docker

# Configure Docker daemon with a specific cgroup driver
echo "Configuring Docker daemon..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

# Restart Docker service to apply configuration changes
echo "Restarting Docker service..."
systemctl restart docker

echo "Docker installation and configuration completed."

# Kubernetes setup

# Add Kubernetes repository configuration
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

# Configure sysctl settings for Kubernetes
echo "Configuring sysctl settings for Kubernetes..."
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply sysctl settings
echo "Applying sysctl settings..."
sysctl --system

# Temporarily disable SELinux
echo "Temporarily disabling SELinux..."
setenforce 0

# Turn off swap
echo "Turning off swap..."
swapoff -a

# Install Kubernetes components
echo "Installing Kubernetes components..."
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Start and enable kubelet service
echo "Starting and enabling kubelet service..."
systemctl enable kubelet
systemctl start kubelet

echo "Kubernetes setup completed."

# Export KUBECONFIG for current session
echo "Exporting KUBECONFIG for the current session..."
export KUBECONFIG=/etc/kubernetes/admin.conf

# Additional commands
echo "Installing iproute..."
yum install iproute -y

# Initialize Kubernetes cluster
echo "Initializing Kubernetes cluster..."
kubeadm init

# Deploy Calico network plugin
echo "Deploying Calico network plugin..."
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml

# Get list of nodes
echo "Getting list of nodes..."
kubectl get nodes

echo "Setup completed."
