#!/bin/bash
sudo yum update -y
sudo yum install libicu -y
cd /home/ec2-user
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-arm64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-arm64-2.308.0.tar.gz
tar xzf ./actions-runner-linux-arm64-2.308.0.tar.gz
./config.sh --url each.key --token each.value --name each.key --unattended
sudo ./svc.sh install
sudo ./svc.sh start