resource "aws_instance" "github_runner_instance" {
  for_each = {
    "test" = {
      "https://github.com/VivaanG1/route53"     = "A7MYWEQZUAQOYSY45ZXH4XLE4SY7S",
      "https://github.com/VivaanG1/vpc-network" = "A7MYWEXXR22B447GYAG5MJDE4S3MM"
      // Add more test repositories here
    },
    "live" = {
      // Empty map for live repositories
    }
  }

  ami           = "ami-02df7c0eecb64fb85"
  instance_type = "t4g.small"
  subnet_id     = "subnet-0140c6f3cbd5d56c7"
  key_name      = "newacct01"

  user_data = templatefile("./stacks/runner/userdata.sh", {
    runner_url   = each.key
    runner_token = each.value
  })

  tags = {
    Name = each.key
  }
}