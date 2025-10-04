
resource "aws_vpc" "this" {
  cidr_block = var.vpc.cidr_block
  tags = {
    Name = var.vpc.name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = var.vpc.internet_gateway_name
  }
}

resource "aws_eip" "this" {
  domain = "vpc"
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = element(aws_subnet.public, 0).id

  tags = {
    Name = var.vpc.nat_gateway_name
  }

  depends_on = [aws_eip.this, aws_internet_gateway.this]
}

