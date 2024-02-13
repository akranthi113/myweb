#!/bin/bash

# Install Java OpenJDK 11
amazon-linux-extras install java-openjdk11 -y && \
if [ $? -ne 0 ]; then
    echo "Error installing Java OpenJDK 11"
    exit 1
fi

# Check if Jenkins is already installed
if ! rpm -q jenkins &> /dev/null; then
    # Download Jenkins repository configuration
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo && \
    if [ $? -ne 0 ]; then
        echo "Error downloading Jenkins repository configuration"
        exit 1
    fi

    # Import Jenkins repository key
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key && \
    if [ $? -ne 0 ]; then
        echo "Error importing Jenkins repository key"
        exit 1
    fi

    # Install Jenkins
    yum install jenkins -y && \
    if [ $? -ne 0 ]; then
        echo "Error installing Jenkins"
        exit 1
    fi

    # Enable Jenkins service
    systemctl enable jenkins && \
    if [ $? -ne 0 ]; then
        echo "Error enabling Jenkins service"
        exit 1
    fi
fi

# Start Jenkins service
systemctl start jenkins && \
if [ $? -ne 0 ]; then
    echo "Error starting Jenkins service"
    exit 1
fi

# Check Jenkins service status
systemctl status jenkins

# Install Git
yum install -y git && \
if [ $? -ne 0 ]; then
    echo "Error installing Git"
    exit 1
fi

# Download Apache Maven repository configuration
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && \
if [ $? -ne 0 ]; then
    echo "Error downloading Apache Maven repository configuration"
    exit 1
fi

# Replace $releasever with 6 in the Maven repository configuration
sed -i 's/\$releasever/6/g' /etc/yum.repos.d/epel-apache-maven.repo && \
if [ $? -ne 0 ]; then
    echo "Error replacing $releasever with 6 in Apache Maven repository configuration"
    exit 1
fi

# Install Apache Maven
yum install -y apache-maven && \
if [ $? -ne 0 ]; then
    echo "Error installing Apache Maven"
    exit 1
fi

# Set Java version to 11
update-alternatives --set java $(update-alternatives --list java | grep 'java-11-openjdk.x86_64') && \
if [ $? -ne 0 ]; then
    echo "Error setting Java version to 11"
    exit 1
fi

# Display initial Jenkins admin password
cat /var/lib/jenkins/secrets/initialAdminPassword && \

# Install Docker
yum install -y docker && \
if [ $? -ne 0 ]; then
    echo "Error installing Docker"
    exit 1
fi

# Start Docker service
systemctl start docker && \
if [ $? -ne 0 ]; then
    echo "Error starting Docker service"
    exit 1
fi

# Add jenkins user to docker group
usermod -aG docker jenkins && \
if [ $? -ne 0 ]; then
    echo "Error adding jenkins user to docker group"
    exit 1
fi

# Set permissions for docker socket
chmod 777 /var/run/docker.sock && \
if [ $? -ne 0 ]; then
    echo "Error setting permissions for docker socket"
    exit 1
fi

echo "Script executed successfully"
