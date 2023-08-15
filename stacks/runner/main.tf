resource "aws_security_group" "runner_sg" {
  name        = "sdp-runner-SG"
  description = "sdp-runner-SG"
  vpc_id      = "vpc-0187b32a2d48cadd4"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "runner_instance" {
  ami                    = "ami-02df7c0eecb64fb85"
  instance_type          = "t4g.small"
  subnet_id              = "subnet-0140c6f3cbd5d56c7"
  vpc_security_group_ids = [aws_security_group.runner_sg.id]
  key_name               = "newacct01"
  user_data              = file("./stacks/runner/userdata.sh")

  tags = {
    Name = var.runner_name
  }
}