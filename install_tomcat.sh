#!/bin/bash

# Install Java 1.8 JDK
sudo yum install -y java-1.8.0-openjdk-devel.x86_64

# Download Tomcat latest version (adjust the version number if needed)
TOMCAT_VERSION=$(curl -s https://archive.apache.org/dist/tomcat/ | grep -oP '(?<=href="v)([0-9]+\.[0-9]+\.[0-9]+)/' | tail -1 | sed 's/\///g')
TOMCAT_DOWNLOAD_URL="https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
wget -P /home/ec2-user "${TOMCAT_DOWNLOAD_URL}"

# Extract Tomcat archive with verbose output
sudo tar -xvf /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /home/ec2-user

# Remove lines containing <Valve> with specific patterns from context.xml
sudo sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="127\.[0-9]\+\.[0-9]\+\.[0-9]\+|::1|0:0:0:0:0:0:0:1" \/>/d' /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml

# Add roles and users to tomcat-users.xml
sudo tee -a /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/conf/tomcat-users.xml > /dev/null <<EOT
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<user username="tomcat" password="tomcat" roles="manager-gui,manager-script"/>
EOT

# Start Tomcat
/home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh

# Display Tomcat version
echo "Apache Tomcat ${TOMCAT_VERSION} has been installed and started successfully."
