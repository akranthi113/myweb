#!/bin/bash

# Script for installing Java and SonarQube

set -e  # Exit immediately if a command exits with a non-zero status

echo "Installing Java..."
yum install -y java-1.8.0-openjdk-devel.x86_64

echo "Downloading SonarQube repository configuration..."
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo

echo "Installing SonarQube..."
sudo yum install sonar -y

echo "Starting SonarQube service..."
sudo service sonar start

echo "SonarQube installation and setup completed."
