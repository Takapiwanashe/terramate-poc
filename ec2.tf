provider "aws" {
  region = "af-south-1"
}

resource "aws_ec2_instance_state" "instance_state" {
  for_each    = toset(["jenkins-master", "jenikns-slave", "ansible"])
  instance_id = aws_instance.web[each.key].id
  state       = "running" #Valid values are stopped | running
}

resource "aws_instance" "web" {
  ami           = "ami-08602ac2d592c8c31"
  instance_type = "t3.medium"
  key_name      = "gladman-new"

  //security_groups = ["demo-sg"]
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id              = aws_subnet.Nam-public-subnet-01.id
  for_each               = toset(["jenkins-master", "jenikns-slave", "ansible"])

  disable_api_termination = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    # Name      = "gc-ansible-solution"
    Name      = "${var.name_prefix}${each.key}"
    Schedule  = "no-schedule" //"stop-at-5-sa"
    Createdby = "gladmanchikosha"
  }
}
variable "name_prefix" {
  default     = "GC-"
  type        = string
  description = "Identify user creating resources"
}

# provider "aws" {
#   region = "us-east-1"
# }
# resource "aws_instance" "demo-server" {
#   ami           = "ami-053b0d53c279acc90"
#   instance_type = "t2.micro"
#   key_name      = "linux-KP"
#   //security_groups = ["demo-sg"]
#   vpc_security_group_ids = [aws_security_group.demo-sg.id]
#   subnet_id              = aws_subnet.Nam-public-subnet-01.id
#   for_each               = toset(["jenkins-master", "jenikns-slave", "ansible"])
#   tags = {
#     Name = "${each.key}"
#   }
# }

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.Nam-vpc.id
  ingress {
    description = "Shh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Jenkins-port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "ssh-port"
  }
}
resource "aws_vpc" "Nam-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Nam-vpc"
  }
}
resource "aws_subnet" "Nam-public-subnet-01" {
  vpc_id                  = aws_vpc.Nam-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "af-south-1a"
  tags = {
    Name = "Nam-public-subent-01"
  }
}
resource "aws_subnet" "Nam-public-subnet-02" {
  vpc_id                  = aws_vpc.Nam-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "af-south-1a"
  tags = {
    Name = "Nam-public-subent-02"
  }
}
resource "aws_internet_gateway" "Nam-igw" {
  vpc_id = aws_vpc.Nam-vpc.id
  tags = {
    Name = "Nam-igw"
  }
}
resource "aws_route_table" "Nam-public-rt" {
  vpc_id = aws_vpc.Nam-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Nam-igw.id
  }
}
resource "aws_route_table_association" "Nam-rta-public-subnet-01" {
  subnet_id      = aws_subnet.Nam-public-subnet-01.id
  route_table_id = aws_route_table.Nam-public-rt.id
}
resource "aws_route_table_association" "Nam-rta-public-subnet-02" {
  subnet_id      = aws_subnet.Nam-public-subnet-02.id
  route_table_id = aws_route_table.Nam-public-rt.id
}
