
#!/bin/bash

# Install Java OpenJDK 11
sudo amazon-linux-extras install java-openjdk11 -y

# Download Jenkins repository configuration
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import Jenkins repository key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Display Jenkins version
jenkins --version

# Check Jenkins service status
service jenkins status

# Enable Jenkins service
sudo systemctl enable jenkins

# Start Jenkins service
sudo systemctl start jenkins

# Install Git
yum install -y git

# Download Apache Maven repository configuration
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo

# Replace $releasever with 6 in the Maven repository configuration
sudo sed -i 's/\$releasever/6/g' /etc/yum.repos.d/epel-apache-maven.repo

# Install Apache Maven
sudo yum install -y apache-maven

# Display initial Jenkins admin password
cat /var/lib/jenkins/secrets/initialAdminPassword

# Update Java version to 11
sudo update-alternatives --set java $(sudo update-alternatives --display java | grep java-11 | awk '{print $1}')
