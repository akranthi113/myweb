#!/bin/bash

# This script installs Docker and Kubernetes on a CentOS/RHEL system

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Docker setup

# Install Docker using yum package manager if not already installed
if ! rpm -q docker > /dev/null; then
    echo "Installing Docker..."
    yum install docker -y
fi

# Start and enable the Docker service
echo "Starting and enabling Docker service..."
systemctl enable docker && systemctl start docker

# Wait until Docker service is started
until systemctl is-active --quiet docker; do
    sleep 1
done
echo "Docker service started and enabled."

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

# Wait until Docker service is restarted
until systemctl is-active --quiet docker; do
    sleep 1
done
echo "Docker installation and configuration completed."

# Kubernetes setup

# Add Kubernetes repository configuration
if [ ! -f /etc/yum.repos.d/kubernetes.repo ]; then
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
fi

# Wait until Kubernetes repository configuration is added
until [ -f /etc/yum.repos.d/kubernetes.repo ]; do
    sleep 1
done
echo "Kubernetes repository configuration added."

# Configure sysctl settings for Kubernetes
echo "Configuring sysctl settings for Kubernetes..."
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Temporarily disable SELinux if not already disabled
if [ $(getenforce) != "Disabled" ]; then
    echo "Disabling SELinux..."
    setenforce 0
fi

# Turn off swap if not already turned off
if [ $(swapon -s | wc -l) -gt 1 ]; then
    echo "Turning off swap..."
    swapoff -a
fi

# Install Kubernetes components if not already installed
if ! rpm -q kubelet kubeadm kubectl > /dev/null; then
    echo "Installing Kubernetes components..."
    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
fi

# Start and enable kubelet service
echo "Starting and enabling kubelet service..."
systemctl enable kubelet && systemctl start kubelet

# Wait until kubelet service is started
until systemctl is-active --quiet kubelet; do
    sleep 1
done
echo "Kubelet service started and enabled."

# Apply Calico networking if not already applied
if ! kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -n kube-system | grep -q calico; then
    echo "Applying Calico networking..."
    kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.15/manifests/calico.yaml
fi

echo "Kubernetes setup completed."

# Add kubeconfig to .bash_profile if not already added
echo "Adding kubeconfig to .bash_profile..."
if ! grep -q "export KUBECONFIG=/etc/kubernetes/admin.conf" ~/.bash_profile; then
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
    echo "Command added to .bash_profile."
fi

# Export KUBECONFIG for current session
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "Setup completed."
