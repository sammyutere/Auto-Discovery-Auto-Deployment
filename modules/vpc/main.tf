resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.name-vpc
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name-igw
  }
}
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = var.name-eip
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    Name = var.name-ngw
  }
}
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.avz1

  tags = {
    Name = var.name-pubsn1
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.avz2

  tags = {
    Name = var.name-pubsn2
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.avz1

  tags = {
    Name = var.name-prvsn1
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.avz2

  tags = {
    Name = var.name-prvsn2
  }
}
#public route table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.name-pub-rt
  }
}

#private route table
resource "aws_route_table" "prv-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.name-prv-rt
  }
}
#Route table associations
resource "aws_route_table_association" "rta-pub1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "rta-pub2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "rta-prv1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.prv-rt.id
}

resource "aws_route_table_association" "rta-prv2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.prv-rt.id
}


