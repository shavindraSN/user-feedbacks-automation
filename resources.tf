##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #

# Define VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags {
    Name = "user_feedbacks-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "user-feedbacks-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  cidr_block        = "${var.public_subnet_cidr}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  map_public_ip_on_launch = false
  tags {
    Name = "user_feedbacks-public-sub"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  cidr_block        = "${var.private_subnet_cidr}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  tags {
    Name = "user_feedbacks-private-sub"
  }
}

resource "aws_subnet" "private_subnet2" {
  cidr_block        = "${var.private_subnet2_cidr}"
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  tags {
    Name = "user_feedbacks-private-sub"
  }
}

# Elastic IP for Nat
resource "aws_eip" "eip" {
  vpc = true
  depends_on = ["aws_internet_gateway.igw"]
  tags {
    Name = "user-feedbacks-eip"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public_subnet.id}"
}


# ROUTING #

# Routing table for public Subnet
resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = ["${aws_subnet.private_subnet.id}", "${aws_subnet.private_subnet2.id}"]

  tags {
    Name = "rds-subnet-group"
  }
}
resource "aws_route_table" "rtb_private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "rtbl-private"
  }
}

resource "aws_route" "route_private" {
  route_table_id = "${aws_route_table.rtb_private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id="${aws_nat_gateway.nat-gw.id}"
}

resource "aws_route_table_association" "rta-public_subnet" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_route_table_association" "rta-private_subnet" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.rtb_private.id}"
}

# SECURITY GROUPS #
resource "aws_security_group" "elb-sg" {
  name        = "elb_sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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

# Public Subnet Security group 
resource "aws_security_group" "public-sg" {
  name        = "public-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private-sg" {
  name = "private-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/24"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.1.0.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

