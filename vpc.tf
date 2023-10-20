provider "aws" {
  region = "us-east-1"
}

# step-1 creating vpc

resource "aws_vpc" "okvpc" {
  cidr_block = var.east_vpc
  tags = {
    Name = "east-vpc"
  }
}

# step-2 creating 1st web subnet

resource "aws_subnet" "Web-1-subnet" {
  vpc_id                  = aws_vpc.okvpc.id
  cidr_block              = var.web1_subnet
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "1st web subnet"
  }
}

# step-3 creating IGW

resource "aws_internet_gateway" "vpc-igw" {
  vpc_id = aws_vpc.okvpc.id
  tags = {
    Name = "okvpc-igw"
  }
}

# step-4 creating public route table

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.okvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-igw.id
  }
  tags = {
    Name = "public route"
  }
}
# associating of web1 public

resource "aws_route_table_association" "pub1-ass" {
  subnet_id      = aws_subnet.Web-1-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
# creating Security group for public

resource "aws_security_group" "pub-sg" {
  vpc_id = aws_vpc.okvpc.id
  # ssh inbound rule
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # httpd inbound rule
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web public sg"
  }
}

# creating web1 pub server httpd server ecomm application

resource "aws_instance" "web-1" {
  ami                    = "ami-067d1e60475437da2"
  vpc_security_group_ids = ["${aws_security_group.pub-sg.id}"]
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  key_name               = "new account"
  subnet_id              = aws_subnet.Web-1-subnet.id
  user_data              = file("data.sh")
  tags = {
    Name = "web1 ecomm"
  }
}
