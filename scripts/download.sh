#!/bin/bash
# Script taken from: https://docs.conduit.io/docs/Deploy/aws_ec2/
TAG=$1

# Download
curl -o conduit.tgz -L "https://github.com/ConduitIO/conduit/releases/download/v${TAG}/conduit_${TAG}_Linux_x86_64.tar.gz"

# Unpack
tar zxvf conduit.tgz

# Create necessary directory structures
sudo cp conduit /usr/bin/
sudo mkdir -p /var/lib/conduit
sudo chown -R ec2-user /var/lib/conduit

sudo mkdir -p /usr/local/lib/systemd/system
sudo chown -R ec2-user /usr/local/lib/systemd/system

printf "[Unit]\nDescription=Conduit daemon\n\n[Service]\nType=simple\nUser=ec2-user\nWorkingDirectory=/var/lib/conduit\nExecStart=/usr/bin/conduit\n\n[Install]\nWantedBy=multi-user.target" >> /usr/local/lib/systemd/system/conduit.service

sudo systemctl enable conduit.service
sudo systemctl start conduit.service
