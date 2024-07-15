# Specify the provider
provider "aws" {
  region = "us-east-1"  # Replace with your preferred region
}

# Define variables (optional, can also be in variables.tf)
variable "key_name" {
  description = "Key-Pair Name"
  default     = "thedivyanshupabia.com"  # Replace with your key pair name
}

variable "instance_type" {
  description = "Type of instance to use"
  default     = "t2.micro"
}

variable "domain_name" {
  description = "Your domain name"
  default     = "thedivyanshupabia.com"  # Replace with your domain name
}

# Create a key pair using the new public key
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("~/.ssh/thedivyanshupabia.com.pub")  # Path to your new public key
}

# Create a security group to allow HTTP and SSH
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP, HTTPS, and SSH"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web" {
  ami             = "ami-06c68f701d8090592"  # Replace with a valid AMI ID for your region
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "MyPortfolioInstance"
  }
}

# Use existing Route 53 hosted zone
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# Create a Route 53 A record to point to the EC2 instance
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web.public_ip]
}

# Output the public IP of the instance
output "instance_ip" {
  description = "The public IP address of the web instance"
  value       = aws_instance.web.public_ip
}