resource "aws_instance" "github_runner_instance" {
  for_each = var.github_repos

  ami                    = "ami-02df7c0eecb64fb85"
  instance_type          = "t4g.small"
  subnet_id              = "subnet-0140c6f3cbd5d56c7"
  vpc_security_group_ids = "sg-0189f66c88b7f3708"
  key_name               = "newacct01"
  user_data              = file("path/to/userdata.sh")

  tags = {
    Name = each.key
  }
}
