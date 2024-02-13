#!/bin/bash

# Install Java 8 JDK
sudo yum install -y java-1.8.0-openjdk-devel.x86_64

# Download SonarQube repository configuration
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo

# Update package index
sudo yum update -y

# Install SonarQube (adjust the version as needed)
SONARQUBE_VERSION="9.2"
sudo yum install -y sonar-${SONARQUBE_VERSION}

# Start SonarQube
sudo systemctl start sonar

# Enable SonarQube to start on boot
sudo systemctl enable sonar

# Display status
echo "SonarQube ${SONARQUBE_VERSION} has been installed and started successfully."
