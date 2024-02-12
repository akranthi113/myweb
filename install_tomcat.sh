#!/bin/bash

# Tomcat version
TOMCAT_VERSION="9.0.85"  # Adjust this version number as needed

# Download Tomcat archive
wget -P /home/ec2-user https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Extract Tomcat archive
tar -xvf /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /home/ec2-user/

# Remove lines containing <Valve> with specific patterns from context.xml
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="127\.[0-9]\+\.[0-9]\+\.[0-9]\+|::1|0:0:0:0:0:0:0:1" \/>/d' /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml

# Add roles and users to tomcat-users.xml
tee -a /home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/conf/tomcat-users.xml > /dev/null <<EOT
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<user username="tomcat" password="tomcat" roles="manager-gui,manager-script"/>
EOT

# Start Tomcat
/home/ec2-user/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh

# Display Tomcat version
echo "Apache Tomcat ${TOMCAT_VERSION} has been installed and started successfully."
