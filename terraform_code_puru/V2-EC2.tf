provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "demo" {
  ami           = "ami-0f71013b2c8bd2c29"
  instance_type = "t2.micro"
  key_name       = "DevOps-Project_Key"
  security_groups = [ aws_security_group.demo-sg ]
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "Allow ssh traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "demo-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# resource "aws_vpc_security_group_ingress_rule" "demo-sg_ipv6" {
#   security_group_id = aws_security_group.demo-sg.id
#   cidr_ipv6         = aws_vpc.main.ipv6_cidr_block
#   from_port         = 443
#   ip_protocol       = "tcp"
#   to_port           = 443
# }

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