# main.tf

# Configure providers
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}


# Filter for the latest upstream Ubuntu AMI
data "aws_ami" "barry_image" {
  most_recent = true

  filter {
    name   = "name"
    values = ["nib-base-win2022-1-*-master"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["441581275790"] # Control General's account ID
}

# Define the security group (and ignore some tfsec findings as some open ports are required for the instance to function properly)
#tfsec:ignore:aws-ec2-no-public-ingress-sgr tfsec:ignore:aws-ec2-no-public-egress-sgr
resource "aws_security_group" "barry" {
  name        = "barry"
  description = "Barry's security group"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow inbound traffic from all sources on port 443"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic from all sources on port 443"
  }
}

# Define the IAM role
resource "aws_iam_role" "barry" {
  name = "barry"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach the SSM managed policy to the role
resource "aws_iam_role_policy_attachment" "barry" {
  role       = aws_iam_role.barry.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Define the instance profile
resource "aws_iam_instance_profile" "barry" {
  name = "barry"
  role = aws_iam_role.barry.name
}

# Define the EC2 instance
resource "aws_instance" "barry" {
  ami           = data.aws_ami.barry_image.id
  instance_type = "m7g.micro"
  vpc_security_group_ids = [aws_security_group.barry.id]
  iam_instance_profile = aws_iam_instance_profile.barry.name

  user_data = <<EOF
        <powershell>
          powershell.exe -File C:\Configure-Instance.ps1
        </powershell>
        EOF

  root_block_device {
    encrypted = "true"
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  tags = {
    Name = "barry-instance"
  }
}

# Define the local state file
terraform {
  backend "local" {
    path = "local.tfstate"
  }
}