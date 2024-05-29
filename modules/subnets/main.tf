resource "aws_subnet" "public_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.pubs1_cidr
  availability_zone = var.avz1

  tags = {
    Name = "${var.name}-public-subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.pubs2_cidr
  availability_zone = var.avz2

  tags = {
    Name = "${var.name}-public-subnet2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.priv1_cidr
  availability_zone = var.avz1

  tags = {
    Name = "${var.name}-private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.priv2_cidr
  availability_zone = var.avz2

  tags = {
    Name = "${var.name}-private-subnet2"
  }
}
