#!/bin/bash
sleep 30
sudo apt-get update -y
sudo apt-get install zip unzip
sudo apt update && sudo apt install --assume-yes curl
sudo apt-get install nginx -y
# curl -sL https://rpm.nodesource.com/setup_18.x | sudo -E bash -
curl -sL https://deb.nodesource.com/setup_19.x | sudo bash -
echo "Setup 19.x"
sudo apt -y install nodejs
echo "Setup Nodejs"
sudo apt-get -y install npm
sudo apt-get install -y gcc g++ make
sudo npm i pm2 -g
sleep 10
echo "Installing AWS CLI"
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sleep 10
sudo aws --version
pwd
echo "Before installing CW"
#Install CLOUD WATCH AGENT
sudo curl -o /root/amazon-cloudwatch-agent.deb https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E /root/amazon-cloudwatch-agent.deb
echo "Creating Launch Template"
aws ec2 create-launch-template-version \
--launch-template-id $TEMPLATE_ID \
--version-description webapp2\
--source-version 1 \
--launch-template-data "ImageId=ami-065557360af5257b3" \
--region us-east-1
sleep 10
unzip webappDEV.zip -d webappDEV
echo "installing npm"
# sudo apt npm i
sleep 30
cd webappDEV && npm i
pwd
echo "Before starting CW"
#start cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c file:/home/ubuntu/webappDEV/statsd/config.json \
-s
echo "Setup statsd"
sudo pm2 start index.js
sudo pm2 ls
sudo pm2 save
sudo pm2 startup systemd