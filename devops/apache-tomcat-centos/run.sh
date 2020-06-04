#! /bin/bash

# Update your CentOS system
sudo yum install epel-release
sudo yum update -y

# Install Java
sudo yum install java-1.8.0-openjdk.x86_64

# Install wget
sudo yum install wget

# Apache Tomcat configuration best practices
# Dedicated User and group for Tomcat
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /sbin/nologin -g tomcat -d /opt/tomcat tomcat

# Installing Apache Tomcat 9
cd ~
wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.35/bin/apache-tomcat-9.0.35.tar.gz
sudo tar -zxvf apache-tomcat-9.0.35.tar.gz -C /opt/tomcat --strip-components=1

# Setting permissions
cd /opt/tomcat
sudo chgrp -R tomcat conf
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod g+r conf/*
sudo chown -R tomcat logs/ temp/ webapps/ work/
sudo chgrp -R tomcat bin
sudo chgrp -R tomcat lib
sudo chmod g+rwx bin
sudo chmod g+r bin/*

# Create a systemd unit file for Tomcat
touch /etc/systemd/system/tomcat.service
cat > /etc/systemd/system/tomcat.service << eof
[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
eof

# Modify firewall rules to allow Tomcat
sudo firewall-cmd --zone=public --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
