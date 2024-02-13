#!/bin/bash

# Change directory to /opt
cd /opt || { echo "Error: Could not change directory to /opt"; exit 1; }

# Install Java 8 JDK development package
yum install -y java-1.8.0-openjdk-devel.x86_64 || { echo "Error: Failed to install Java 8 JDK"; exit 1; }

# Download SonarQube repository configuration
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo || { echo "Error: Failed to download SonarQube repository configuration"; exit 1; }

# Install SonarQube package
sudo yum install sonar -y || { echo "Error: Failed to install SonarQube package"; exit 1; }

# Start SonarQube service
sudo service sonar start || { echo "Error: Failed to start SonarQube service"; exit 1; }

# Check SonarQube service status
sudo service sonar status || { echo "Warning: SonarQube service is not running"; }

echo "SonarQube service started successfully."
