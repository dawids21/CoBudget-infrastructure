resource "aws_vpc" "cobudget" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cobudget" {
  vpc_id = aws_vpc.cobudget.id
}

resource "aws_subnet" "cobudget_public" {
  vpc_id     = aws_vpc.cobudget.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "cobudget_private" {
  vpc_id     = aws_vpc.cobudget.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "cobudget_private2" {
  vpc_id     = aws_vpc.cobudget.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_route_table" "cobudget_public" {
  vpc_id = aws_vpc.cobudget.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cobudget.id
  }
}

resource "aws_route_table_association" "cobudget_public" {
  route_table_id = aws_route_table.cobudget_public.id
  subnet_id      = aws_subnet.cobudget_public.id
}

resource "aws_route_table" "cobudget_private" {
  vpc_id = aws_vpc.cobudget.id
}

resource "aws_route_table_association" "cobudget_private" {
  route_table_id = aws_route_table.cobudget_private.id
  subnet_id      = aws_subnet.cobudget_private.id
}

resource "aws_route_table_association" "cobudget_private2" {
  route_table_id = aws_route_table.cobudget_private.id
  subnet_id      = aws_subnet.cobudget_private2.id
}
