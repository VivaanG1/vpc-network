resource "aws_instance" "github_runner_instance" {
  for_each = var.github_repos

  ami           = "ami-02df7c0eecb64fb85"
  instance_type = "t4g.small"
  subnet_id     = "subnet-0140c6f3cbd5d56c7"
  key_name      = "newacct01"
  user_data     = <<-EOT
    #!/bin/bash
    sudo yum install libicu -y
    cd /home/ec2-user
    mkdir actions-runner && cd actions-runner
    curl -o actions-runner-linux-arm64-2.308.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.308.0/actions-runner-linux-arm64-2.308.0.tar.gz
    tar xzf ./actions-runner-linux-arm64-2.308.0.tar.gz
    sudo chown -R ec2-user:ec2-user ../actions-runner/
    echo "URL: ${each.key}" >> /tmp/config.log
    echo "Token: ${each.value}" >> /tmp/config.log
    ./config.sh --url "${each.key}" --token "${each.value}" --unattended >> /tmp/config.log 2>&1
    sudo ./svc.sh install
    sudo ./svc.sh start
    EOT

  tags = {
    Name = each.key
  }
}
