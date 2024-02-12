
#!/bin/bash

# Update package index
sudo yum update -y

# Install Java OpenJDK 1.8 development kit
sudo yum install -y java-1.8.0-openjdk-devel.x86_64

# Download Tomcat latest version (adjust the version number if needed)
TOMCAT_VERSION=9.0.85
TOMCAT_DOWNLOAD_URL="https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
wget -P /tmp "${TOMCAT_DOWNLOAD_URL}"

# Extract Tomcat archive
sudo tar xf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt

# Create a symbolic link
sudo ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# Configure environment variables
echo "export CATALINA_HOME=\"/opt/tomcat\"" | sudo tee -a /etc/profile.d/tomcat.sh
echo "export PATH=\"\$CATALINA_HOME/bin:\$PATH\"" | sudo tee -a /etc/profile.d/tomcat.sh

# Reload environment variables
source /etc/profile.d/tomcat.sh

# Remove <Valve> and <Allow> tags from context.xml
sudo sed -i '/<Valve/d' /opt/tomcat/conf/context.xml
sudo sed -i '/<Allow>/d' /opt/tomcat/conf/context.xml

# Add roles and users to tomcat-users.xml
sudo tee -a /opt/tomcat/conf/tomcat-users.xml > /dev/null <<EOT
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<user username="tomcat" password="tomcat" roles="manager-gui,manager-script"/>
EOT

# Start Tomcat
sudo /opt/tomcat/bin/startup.sh

# Display Tomcat version
echo "Apache Tomcat ${TOMCAT_VERSION} has been installed and started successfully."
