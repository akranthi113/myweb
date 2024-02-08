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
yum install docker -y && echo "Completed." &&

# Start and enable the Docker service
echo "Starting and enabling Docker service..."
systemctl enable docker && systemctl start docker && echo "Completed." &&

# Configure Docker daemon with a specific cgroup driver
echo "Configuring Docker daemon..."
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF && echo "Completed." &&

# Restart Docker service to apply configuration changes
echo "Restarting Docker service..."
systemctl restart docker && echo "Completed." &&

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
EOF && echo "Completed." &&

# Configure sysctl settings for Kubernetes
echo "Configuring sysctl settings for Kubernetes..."
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF && echo "Completed." &&

# Apply sysctl settings
echo "Applying sysctl settings..."
sysctl --system && echo "Completed." &&

# Temporarily disable SELinux
echo "Disabling SELinux..."
setenforce 0 && echo "Completed." &&

# Turn off swap
echo "Turning off swap..."
swapoff -a && echo "Completed." &&

# Install Kubernetes components
echo "Installing Kubernetes components..."
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes && echo "Completed." &&

# Start and enable kubelet service
echo "Starting and enabling kubelet service..."
systemctl enable kubelet && systemctl start kubelet && echo "Completed." &&

# Apply Calico networking
echo "Applying Calico networking..."
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml && echo "Completed." &&

echo "Kubernetes setup completed."

# Add kubeconfig to .bash_profile
echo "Adding kubeconfig to .bash_profile..."
if grep -q "export KUBECONFIG=/etc/kubernetes/admin.conf" ~/.bash_profile; then
    echo "The command is already present in .bash_profile."
else
    # Add the command to .bash_profile using vi editor
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile &&
    echo "Command added to .bash_profile."
fi &&

# Export KUBECONFIG for current session
export KUBECONFIG=/etc/kubernetes/admin.conf &&

echo "Setup completed."
