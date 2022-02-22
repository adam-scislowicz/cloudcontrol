provider "aws" {
	region = "us-west-1"
}

resource "aws_security_group" "allow_inbound_ssh_only" {
  name        = "allow_inbound_ssh_only"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.aws_ncal_vpc.id

  ingress {
    description = "inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dataplane_security_group" {
  name        = "dataplane_security_group"
  description = "Dataplane Interface Security Group"
  vpc_id      = aws_vpc.aws_ncal_vpc.id

  ingress {
    description = "tbd"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "aws_ncal_vpc" {
  cidr_block = cidrsubnet("10.0.0.0/8", 8, 8)
}

resource "aws_internet_gateway" "aws_ncal_gw" {
  vpc_id = aws_vpc.aws_ncal_vpc.id
}

resource "aws_subnet" "aws_ncal_subnet" {
  vpc_id     = aws_vpc.aws_ncal_vpc.id
  cidr_block = cidrsubnet(aws_vpc.aws_ncal_vpc.cidr_block, 8, 8)
  map_public_ip_on_launch = true
  depends_on = [aws_internet_gateway.aws_ncal_gw]
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.aws_ncal_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws_ncal_gw.id
    }
}

resource "aws_route_table_association" "public_route_table_assoc" {
    subnet_id = aws_subnet.aws_ncal_subnet.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_network_interface" "vpop-nic-1-for-i0001" {
  subnet_id       = aws_subnet.aws_ncal_subnet.id
  security_groups = [ aws_security_group.dataplane_security_group.id ]

  attachment {
    instance     = aws_instance.virtual-pop-i0001.id
    device_index = 2
  }
}

resource "aws_instance" "virtual-pop-i0001" {
  subnet_id = aws_subnet.aws_ncal_subnet.id
	ami = "ami-0111167296760a240"
	instance_type = "t2.micro"
	key_name = "dev-virtual-pop"
	#user_data = file("debian-buster-bootstrap.sh")

	private_ip = cidrhost(aws_subnet.aws_ncal_subnet.cidr_block, 16)

  vpc_security_group_ids = [ aws_security_group.allow_inbound_ssh_only.id ]

	root_block_device {
		volume_size = 256
	}
}

resource "aws_eip" "vpop-eip-1-for-i0001" {
  vpc = true

  instance                  = aws_instance.virtual-pop-i0001.id
  associate_with_private_ip = aws_instance.virtual-pop-i0001.private_ip
  depends_on                = [aws_internet_gateway.aws_ncal_gw]
}

#resource "aws_instance" "load-generator" {
#        subnet_id = aws_subnet.aws_ncal_subnet.id
#	ami = "ami-0f1b197c32657bd44"
#	instance_type = "m5n.4xlarge"
#	key_name = "dev-virtual-pop"
#	user_data = file("debian-buster-bootstrap.sh")
#
#	private_ip = cidrhost(aws_subnet.aws_ncal_subnet.cidr_block, 32)
#
#  	vpc_security_group_ids = [ aws_security_group.allow_inbound_ssh_only.id ]
#
#	root_block_device {
#		volume_size = 32
#	}
#}

#resource "aws_eip" "vpop-eip-1-for-load-generator" {
#  vpc = true
#
#  instance                  = aws_instance.load-generator.id
#  associate_with_private_ip = aws_instance.load-generator.private_ip
#  depends_on                = [aws_internet_gateway.aws_ncal_gw]
#}
