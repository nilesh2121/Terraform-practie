resource "aws_vpc" "hcl" {
    cidr_block = var.network_cidrs
    tags = {
      Name = "hcl"
    }
  
}
# resouces need to add subnets , count of subnets  cidr_block rainges , subnet name,  availability zhone, VPC id  you mentioned in the inputs file
# resource "aws_subnet" "subnets" {
#     count = 2
#     cidr_block = var.subnet_cidrs[count.index]
#     vpc_id = aws_vpc.hcl.id
#     tags = {
#       Name = var.subnet_name_tags[count.index]
#     }
#     availability_zone = var.subnet_azs[count.index]
    
# }

resource "aws_subnet" "public_subnet" {
  cidr_block = var.subnet_cidrs_public
  vpc_id = aws_vpc.hcl.id
  tags = {
    Name = "public subnets"
  }
  availability_zone = var.subnet_azs_1a
  
}

resource "aws_subnet" "private_subnet" {
  cidr_block = var.subnet_cidrs_private
  vpc_id = aws_vpc.hcl.id
  tags = {
    Name = "private subnets"
  }
  availability_zone = var.subnet_azs_1b
}



# add the internet gateway 
resource "aws_internet_gateway" "hcl-igw" {
    vpc_id = aws_vpc.hcl.id
    tags = {
      Name = "hcl internet gateway"
    }

  
}

resource "aws_security_group" "websg" {
  vpc_id = aws_vpc.hcl.id
  description = "security group created from terraform"
  ingress {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web SG"
  }

}

resource "aws_security_group" "dbsg" {
  vpc_id = aws_vpc.hcl.id
  description = "security group created from terraform"
  
    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
  }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "db SG"
  }

}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.hcl.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hcl-igw.id

  }
  tags = {
    Name = "Public RT"
  }
  
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.hcl.id
  tags = {
    Name = "Private RT"
  }
}

resource "aws_route_table_association" "association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.publicrt.id
  
}

