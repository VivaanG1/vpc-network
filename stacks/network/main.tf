resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/20" # Adjust the CIDR block as per your requirements

  tags = {
    Name = "${var.environment}-sdp-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sdp-igw"
  }
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"] # Update with your desired AZs
}

resource "aws_subnet" "public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index}.0/24" # Adjust the CIDR block as needed
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-sdp-PublicSubnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24" # Adjust the CIDR block as needed
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-sdp-PrivateSubnet-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.environment}-sdp-ngw"
  }
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "${var.environment}-sdp-eip"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-sdp-public-rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sdp-private-rt"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_iam_role" "flow_log_role" {
  name               = "${var.environment}-sdp-flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
  role       = aws_iam_role.flow_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSFlowLogFullAccess"
}

resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "${var.environment}-sdp-flow-logs"
}

resource "aws_flow_log" "flow_log" {
  depends_on      = [aws_vpc.vpc]
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.flow_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}