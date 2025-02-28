sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade

sudo dnf install java-17-amazon-corretto -y

sudo yum install jenkins -y

sudo systemctl enable jenkins






# resize the size of temperary folder
sudo mount -o remount,size=2G /tmp


#!/bin/bash

# Define the file path
FILE="/etc/fstab"

# Check if the file exists, create if not
if [ ! -f "$FILE" ]; then
    touch "$FILE"
fi

# Check if the line already exists to avoid duplicates
if ! grep -q "^tmpfs /tmp tmpfs defaults,size=2G 0 0" "$FILE"; then
    # Append the line
    echo "tmpfs /tmp tmpfs defaults,size=2G 0 0" >> "$FILE"
    echo "Entry added to $FILE"
else
    echo "Entry already exists in $FILE"
fi



sudo systemctl daemon-reload


sudo systemctl enable jenkins

sudo systemctl restart jenkins
sudo yum install git -y
df -h

sudo systemctl status jenkins
