#!/bin/bash
sudo yum update -y
sudo yum install libicu -y
cd /home/ec2-user
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-arm64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-arm64-2.308.0.tar.gz
tar xzf ./actions-runner-linux-arm64-2.308.0.tar.gz
sudo chown -R ec2-user:ec2-user ../actions-runner/
su - ec2-user -c "/home/ec2-user/actions-runner/config.sh --url ${runner_url} --token ${runner_token} --unattended"
sudo ./svc.sh install
sudo ./svc.sh start