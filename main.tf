resource "aws_vpc" "clc_vpc" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-terraform-v2"
  }
}
resource "aws_subnet" "public_subnet_1a" {
  vpc_id     = aws_vpc.clc_vpc.id
  cidr_block = "172.16.1.0/24"
  availability_zone = "us-east-1a" 
  tags = {
    Name = "public_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id     = aws_vpc.clc_vpc.id
  cidr_block = "172.16.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_1a"
  }
}

## Cria internet gateway com a referência da vpc clc_vpc 
resource "aws_internet_gateway" "gw_clc_vpc" {
  vpc_id = aws_vpc.clc_vpc.id

  tags = {
    Name = "igw-clc_vpc"
  }
}

## Cria tabela de rota publica com rota para o internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.clc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_clc_vpc.id
  }

  tags = {
    Name = "public-rt"
  }
}

## Associa a tabela de rota publica com a subrede publica 1a
resource "aws_route_table_association" "rt_pub_association_subnet_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt.id
}

## Cria um IP público para nat gateway 1a ##
resource "aws_eip" "eip_nat_gw_1a" {
  domain   = "vpc"
}

## Cria o nat gateway da zona de disponibilidade 1A ## 
resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.eip_nat_gw_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = {
    Name = "nat_gw_1a_tf"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw_clc_vpc]
}

## Cria tabela de rota privada 1A com rota para o NAT Gateway da 1A
resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.clc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
  }

  tags = {
    Name = "private_rt_1a_tf"
  }
}

## Associa a tabela de rota privada 1a na subnet privada 1a ##
resource "aws_route_table_association" "rt_priv_association_subnet_1a" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}
