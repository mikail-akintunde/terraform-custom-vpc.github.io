#1 Create ec2 instance
resource "aws_vpc" "my-first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo"
  }
}

#2 Configure IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-first-vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# 3: Create Custom Route Table
resource "aws_route_table" "my-RT" {
  vpc_id = aws_vpc.my-first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "demo-RT"
  }
}

#4: Create a Custom Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.my-first-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "demo-subnet"
  }
}

#5: Subnet Association 
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my-RT.id
}

#6: Create a security Group
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my-first-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "demo-SG"
  }
}

#7: Creating a network interface
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

#8: create e.i
resource "aws_eip" "my-Fist-EIP" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.igw]
}

#9: Creare ec2 instance 
resource "aws_instance" "my-first-ec2-deployment" {
  ami               = "ami-0ed9277fb7eb570c9"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "MY-DEMO-KEY" # key pair was created on ec2 inatance dashbord and must be reference here

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd.x86_64
              sudo systemctl start httpd.service
              sudo systemctl enable httpd.service
              sudo echo “Hello World from $(hostname -f)” > /var/www/html/index.html
              EOF
  tags = {
    Name = "web-server"
  }
}

# resource "<provider>_<resource_type>" "name" {
#     config options......
#     key = "value"
#     key2 = "another value"

# }