provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "demo" {
  ami           = "ami-0f71013b2c8bd2c29"
  instance_type = "t2.micro"
  key_name       = "DevOps-Project_Key"
}
