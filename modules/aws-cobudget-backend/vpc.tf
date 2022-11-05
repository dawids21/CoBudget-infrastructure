resource "aws_vpc" "cobudget" {
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "cobudget" {
  vpc_id = aws_vpc.cobudget.id
}

resource "aws_subnet" "cobudget_public" {
  for_each   = toset(var.vpc_cidr_public)
  vpc_id     = aws_vpc.cobudget.id
  cidr_block = each.value
}

resource "aws_subnet" "cobudget_private" {
  for_each   = toset(var.vpc_cidr_private)
  vpc_id     = aws_vpc.cobudget.id
  cidr_block = each.value
}

resource "aws_route_table" "cobudget_public" {
  vpc_id = aws_vpc.cobudget.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cobudget.id
  }
}

resource "aws_route_table_association" "cobudget_public" {
  for_each       = aws_subnet.cobudget_public
  route_table_id = aws_route_table.cobudget_public.id
  subnet_id      = each.value.id
}

resource "aws_route_table" "cobudget_private" {
  vpc_id = aws_vpc.cobudget.id
}

resource "aws_route_table_association" "cobudget_private" {
  for_each       = aws_subnet.cobudget_private
  route_table_id = aws_route_table.cobudget_private.id
  subnet_id      = each.value.id
}