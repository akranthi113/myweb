#!/bin/bash

# Install Java OpenJDK 11
amazon-linux-extras install java-openjdk11 -y

# Install Docker
yum install -y docker

# Start Docker service
service docker start

# Download Jenkins repository configuration
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins repository key
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
yum install jenkins -y

# Display Jenkins version (assuming jenkins executable is located at /usr/bin/jenkins)
/usr/bin/jenkins --version

# Check Jenkins service status
systemctl status jenkins

# Enable Jenkins service
systemctl enable jenkins

# Start Jenkins service
systemctl start jenkins

# Install Git
yum install -y git

# Download Apache Maven repository configuration
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo

# Replace $releasever with 6 in the Maven repository configuration
sed -i 's/\$releasever/6/g' /etc/yum.repos.d/epel-apache-maven.repo

# Install Apache Maven
yum install -y apache-maven

# Update Java version to 11
update-alternatives --set java $(update-alternatives --list java | grep 'java-11-openjdk.x86_64')

# Display initial Jenkins admin password
cat /var/lib/jenkins/secrets/initialAdminPassword

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Set permissions for docker socket
chmod 777 /var/run/docker.sock
