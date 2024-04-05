#!/bin/bash

# Install Java OpenJDK 11
sudo amazon-linux-extras install java-openjdk11 -y

# Configure Jenkins Repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins Repository Key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Check Jenkins Version
jenkins --version

# Check Jenkins Service Status
service jenkins status

# Enable Jenkins Service
sudo systemctl enable jenkins

# Start Jenkins Service
sudo systemctl start jenkins

# Retrieve Jenkins Initial Admin Password
cat /var/lib/jenkins/secrets/initialAdminPassword
