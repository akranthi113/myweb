#!/bin/bash

# Install Java 1.8
sudo yum install -y java-1.8.0-openjdk-devel.x86_64

# Change directory to /opt/
cd /opt/

# Download Nexus tarball
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract Nexus tarball
tar -xvf latest-unix.tar.gz

# Rename Nexus directory
mv nexus-3.65.0-02 nexus3

# Set ownership
sudo chown -R ec2-user:ec2-user nexus3 sonatype-work

# Change directory to Nexus
cd nexus3/

# Create symbolic link for Nexus service
sudo ln -s /opt/nexus3/bin/nexus /etc/init.d/nexus

# Add Nexus service to system startup
sudo chkconfig --add nexus
sudo chkconfig nexus on

# Start Nexus service
sudo service nexus start

# Display admin password
cat /opt/sonatype-work/nexus3/admin.password
