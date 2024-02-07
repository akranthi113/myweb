#!/bin/bash

# Install Java
yum install -y java-1.8.0-openjdk-devel.x86_64

# Download SonarQube repository configuration
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo

# Install SonarQube
sudo yum install sonar -y

# Start SonarQube service
sudo service sonar start
