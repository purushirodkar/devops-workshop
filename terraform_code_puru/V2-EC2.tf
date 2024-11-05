provider "aws" {
  region = "ap-southeast-2"
}


resource "aws_instance" "demo" {
  ami                    = "ami-001f2488b35ca8aad"
  instance_type          = "t2.micro"
  key_name               = "DevOps-Project_Key"
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id              = aws_subnet.dpw-public_subent_01.id

  for_each = toset(["jenkins-master", "build-slave", "ansible"])
  tags = {
    Name = "${each.key}"
  }

}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.dpw-vpc.id

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc" "dpw-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpw-vpc"
  }
}

resource "aws_subnet" "dpw-public_subent_01" {
  vpc_id                  = aws_vpc.dpw-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2a"
  tags = {
    Name = "dpw-public_subent_01"
  }
}

resource "aws_subnet" "dpw-public_subent_02" {
  vpc_id                  = aws_vpc.dpw-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-southeast-2b"
  tags = {
    Name = "dpw-public_subent_02"
  }
}

resource "aws_internet_gateway" "dpw-igw" {
  vpc_id = aws_vpc.dpw-vpc.id
  tags = {
    Name = "dpw-igw"
  }
}

resource "aws_route_table" "dpw-public-rt" {
  vpc_id = aws_vpc.dpw-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpw-igw.id
  }
  tags = {
    Name = "dpw-public-rt"
  }
}

resource "aws_route_table_association" "dpw-rta-public-subent-1" {
  subnet_id      = aws_subnet.dpw-public_subent_01.id
  route_table_id = aws_route_table.dpw-public-rt.id
}

resource "aws_route_table_association" "dpw-rta-public-subent-2" {
  subnet_id      = aws_subnet.dpw-public_subent_02.id
  route_table_id = aws_route_table.dpw-public-rt.id
}