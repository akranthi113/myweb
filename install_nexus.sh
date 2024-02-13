#!/bin/bash

# Change directory to /opt
cd /opt

# Install Java 8 JDK development package
sudo yum install -y java-1.8.0-openjdk-devel.x86_64

# Download Nexus tarball
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract Nexus tarball
tar -xvf latest-unix.tar.gz

# Rename Nexus directory
mv nexus-3.65.0-02 nexus3

# Change ownership of Nexus directories
sudo chown -R ec2-user:ec2-user nexus3 sonatype-work

# Change directory to Nexus bin
cd nexus3/bin

# Modify nexus.rc to set run_as_user
sed -i 's/#run_as_user=""/run_as_user="ec2-user"/' nexus.rc

# Create symlink for Nexus in /etc/init.d
sudo ln -s /opt/nexus3/bin/nexus /etc/init.d/nexus

# Add Nexus as a service
sudo chkconfig --add nexus
sudo chkconfig nexus on

# Start Nexus service
sudo service nexus start

# Wait for Nexus to start (adjust sleep time as needed)
sleep 20

# Change directory to /opt
cd /opt

# Display initial admin password
cat /opt/sonatype-work/nexus3/admin.password
