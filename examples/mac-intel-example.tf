# Build Mac 1 

variable "mac_instance_type1" {
  default = "mac1.metal"
}

resource "aws_ec2_host" "operator_mac_host1" {
  instance_type     = var.mac_instance_type1
  availability_zone = data.aws_availability_zones.available.names[1]
}

# Build security groups for this Mac
resource "aws_security_group" "mac1_ingress" {
  name   = "mac1-ingress"
  vpc_id = aws_vpc.operator.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.src_ip]
  }

  # Self
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # Allow VPC all
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "aws_ami" "macos1" {
  most_recent      = true
  owners = ["amazon"] # Amazon

  filter {
    name   = "name"
    values = ["amzn-ec2-macos-13*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Change filter value to 'x86_64_mac' for Apple Intel 
  filter {
    name = "architecture"
    values = ["x86_64_mac"]
  }

}

resource "aws_instance" "mac_instance1" {
  ami           = data.aws_ami.macos1.id
  host_id       = aws_ec2_host.operator_mac_host1.id 
  instance_type = var.mac_instance_type1 
  subnet_id     = aws_subnet.user_subnet.id
  key_name      = module.key_pair.key_pair_name 
  vpc_security_group_ids = [aws_security_group.mac1_ingress.id]

  tags = {
    Name = "mac1"
  }

  user_data = templatefile("files/mac/bootstrap.sh.tpl", {
    s3_bucket                 = "${aws_s3_bucket.staging.id}"
    region                    = var.region
  })

}
output "mac_details_1" {
  value = <<EOS
-------------------------
Virtual Machine ${aws_instance.mac_instance1.tags["Name"]}
-------------------------
Instance ID: ${aws_instance.mac_instance1.id}
Instance Type: ${var.mac_instance_type1}
Computer Name:  ${aws_instance.mac_instance1.tags["Name"]}
Private IP: ${aws_instance.mac_instance1.private_ip}
Public IP:  ${aws_instance.mac_instance1.public_ip}
Public DNS: ${aws_instance.mac_instance1.public_dns}

SSH Access - Mac 1
----------
ssh -i ssh_key.pem ec2-user@${aws_instance.mac_instance1.public_dns}

EOS
}