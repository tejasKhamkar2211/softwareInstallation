#!/bin/bash

# Exit on any error
set -e

# Add Prometheus repository
sudo tee /etc/yum.repos.d/prometheus.repo <<EOF
[prometheus]
name=Prometheus
baseurl=https://packagecloud.io/prometheus-rpm/release/el/7/x86_64
repo_gpgcheck=1
enabled=1
gpgkey=https://packagecloud.io/prometheus-rpm/release/gpgkey https://raw.githubusercontent.com/lest/prometheus-rpm/master/RPM-GPG-KEY-prometheus-rpm
gpgcheck=1
metadata_expire=300
EOF

# Update system packages
sudo yum update -y

# Install Prometheus and Node Exporter
sudo yum -y install prometheus2 node_exporter

# Verify installation
rpm -qi prometheus2

# Start Prometheus and Node Exporter
sudo systemctl start prometheus node_exporter
sudo systemctl enable prometheus node_exporter

# Check the status of the services
systemctl status prometheus.service node_exporter.service

# Install Grafana
sudo yum install -y https://dl.grafana.com/oss/release/grafana-10.0.3-1.x86_64.rpm

# Start and enable Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Print success message
echo "Installation complete. Add port 9090 in your security group, then access Prometheus via: http://<your-ec2-public-ip>:9090"
echo "Grafana can be accessed via: http://<your-ec2-public-ip>:3000"
