#!/bin/bash

# This script installs Kubernetes on a CentOS/RHEL system

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

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

# Configure sysctl settings for Kubernetes
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply sysctl settings
sysctl --system

# Temporarily disable SELinux
setenforce 0

# Turn off swap
swapoff -a

# Install Kubernetes components
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Start and enable kubelet service
systemctl enable kubelet
systemctl start kubelet

# Apply Calico networking
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml

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
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Setup completed."
