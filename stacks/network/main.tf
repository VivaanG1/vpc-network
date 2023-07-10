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
  default = ["eu-west-1a", "eu-west-1b"] # Update with your desired AZs
}

resource "aws_subnet" "public_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index}.0/24" # Adjust the CIDR block as needed
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-sdp-PublicSubnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.${count.index + 10}.0/24" # Adjust the CIDR block as needed
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.environment}-sdp-PrivateSubnet-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "${var.environment}-sdp-nat-gateway-${count.index + 1}"
  }
}

resource "aws_eip" "nat_eip" {
  count = 2
  vpc   = true

  tags = {
    Name = "${var.environment}-sdp-eip-${count.index + 1}"
  }
}

# Create Public Route Tables
resource "aws_route_table" "public_route_table" {
  count    = 2
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "PublicRouteTable-${count.index + 1}"
  }
}

# Create Private Route Tables
resource "aws_route_table" "private_route_table" {
  count    = 2
  vpc_id   = aws_vpc.vpc.id

  tags = {
    Name = "PrivateRouteTable-${count.index + 1}"
  }
}

# Associate Public Subnets with Public Route Tables
resource "aws_route_table_association" "public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

# Create Default Routes in Private Route Tables via NAT Gateways
resource "aws_route" "private_default_route" {
  count                 = 2
  route_table_id        = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id        = aws_nat_gateway.nat_gateway[count.index].id
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