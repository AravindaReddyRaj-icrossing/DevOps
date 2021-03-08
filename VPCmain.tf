resource "aws_vpc" "myvpc" {
    cidr_block = var.vpccidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      "Name" = "myvpc"
    }
  
}

resource "aws_subnet" "myvpcsubnets" {
  count = length(local.subnets)
  vpc_id = aws_vpc.myvpc.id
  cidr_block = cidrsubnet(var.vpccidr,8,count.index)
  availability_zone = "${var.region}${count.index%2==0?"a":"b"}"

  tags = {
    "Name" = local.subnets[count.index]
  }
  depends_on = [ aws_vpc.myvpc ]
}

resource "aws_internet_gateway" "myvpcig" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = local.igw_name
  }
  depends_on = [ aws_vpc.myvpc ]
}

resource "aws_route_table" "myvpcpubrt" {
  vpc_id = aws_vpc.myvpc.id  

  route  {
    cidr_block = local.anywhere
    gateway_id = aws_internet_gateway.myvpcig.id    
  } 

  tags = {
    "Name" = "myvpcpubrt"
  }

  depends_on = [ 
    aws_vpc.myvpc,
    aws_subnet.myvpcsubnets[0],
    aws_subnet.myvpcsubnets[1]
   ]

}

resource "aws_route_table" "myvpcprirt" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "myvpcprirt"
  }

  depends_on = [ 
    aws_vpc.myvpc,
    aws_subnet.myvpcsubnets[2],
    aws_subnet.myvpcsubnets[3],
    aws_subnet.myvpcsubnets[4],
    aws_subnet.myvpcsubnets[5]
   ]
  
}

resource "aws_route_table_association" "myvpcrta" {
  count = 2
  subnet_id = aws_subnet.myvpcsubnets[count.index].id
  route_table_id = aws_route_table.myvpcpubrt.id

  depends_on = [ aws_route_table.myvpcpubrt ]

}

resource "aws_route_table_association" "myvpcrtb" {
  count = 4
  subnet_id = aws_subnet.myvpcsubnets[count.index+2].id
  route_table_id = aws_route_table.myvpcprirt.id

  depends_on = [ aws_route_table.myvpcprirt]
  
}

resource "aws_security_group" "myvpcwebsg" {
  name = "myvpcwebsg"
  description = "Allow 80 and 22 ports in VPC"
  vpc_id = aws_vpc.myvpc.id

  ingress  {
    cidr_blocks = [var.vpccidr]
    description = "allow 80 port"
    from_port = local.http
    protocol = local.tcp
    to_port = local.http
  } 
  ingress {
    cidr_blocks = [var.vpccidr]
    description = "allow 22 port"
    from_port = local.ssh
    protocol = local.tcp
    to_port = local.ssh
  } 
  tags = {
    "Name" = "myvpcwebsg"
  }

  depends_on = [ aws_route_table.myvpcpubrt, aws_route_table.myvpcprirt ]
  
}

resource "aws_security_group" "myvpcappsg" {
  name = "myvpcappsg"
  description = "Allow 8080 and 22 ports in VPC"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    cidr_blocks = [var.vpccidr]
    description = "allow 8080 port"
    from_port = local.app
    protocol = local.tcp
    to_port = local.app
  }

  ingress {
    cidr_blocks = [var.vpccidr]
    description = "allow 22 port"
    from_port = local.ssh
    protocol = local.tcp
    to_port = local.ssh
  }  
  tags = {
    "Name" = "myvpcappsg"
  }

  depends_on = [ aws_route_table.myvpcpubrt, aws_route_table.myvpcprirt ]
}

resource "aws_security_group" "myvpcdbsg" {
  name = "myvpcdbsg"
  description = "allow 3306 port in VPC"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    cidr_blocks = [var.vpccidr]
    description = "allow 3306 port"
    from_port = local.db
    to_port = local.db
    protocol = local.tcp
  }

  tags = {
    "Name" = "myvpcdbsg"
  }

  depends_on = [ aws_route_table.myvpcpubrt, aws_route_table.myvpcprirt ]
  
}