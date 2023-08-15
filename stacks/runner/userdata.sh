#!/bin/bash
sudo yum update -y
sudo yum install libicu -y
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-arm64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-arm64-2.308.0.tar.gz
tar xzf ./actions-runner-linux-arm64-2.308.0.tar.gz
./config.sh --url "${repo_url}" --token "${github_runner_token}" --name "${runner_name}" --labels "${runner_name}" --unattended
sudo ./svc.sh install
sudo ./svc.sh start