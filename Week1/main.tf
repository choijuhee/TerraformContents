# Provider for AWS
provider "aws" {
  region = "ap-northeast-2"
}

#Terraform Backend 
#S3 : store state file
#DDB : store state lock info
terraform{
  backend "s3" {
    bucket         = "terraform-backend-juheec"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-backend"
  }
}

# Variable for Security Group of EC2 Instance
variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance"
}

#Resources
#EC2
#Security Group
#Security Group in/egress rule

resource "aws_instance" "example" {
  ami                    = "ami-0c9c942bd7bf113a2"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              sleep 60
              sudo apt-get -y update
              sudo apt-get -y install apache2
              sudo service apache2 start
              echo "Hello, JUHEEC" > /var/www/html/index.html
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "apache-web"
  }
}

resource "aws_security_group" "instance" {
  name = var.security_group_name
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

#Output
#EC2 instance's Public IP

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}
