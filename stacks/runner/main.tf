resource "aws_instance" "github_runner_instance" {
  for_each = var.github_repos

  ami           = "ami-02df7c0eecb64fb85"
  instance_type = "t4g.small"
  subnet_id     = "subnet-0140c6f3cbd5d56c7"
  key_name      = "newacct01"
  user_data     = file("./stacks/runner/userdata.sh")

  tags = {
    Name = each.key
  }
}
