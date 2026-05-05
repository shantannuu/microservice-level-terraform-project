//vpc module
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.env}-vpc"
  })
}


//internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.env}-igw"
  })
}


//public subnet
resource "aws_subnet" "public" {
  for_each = zipmap(var.azs, var.public_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.env}-public-subnet-${each.key}"
    type = "public"
  })
}


//private subnet
resource "aws_subnet" "private" {
  for_each = zipmap(var.azs, var.private_subnets)

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = merge(local.common_tags, {
    Name = "${var.env}-private-subnet-${each.key}"
    type = "private"
  })
}


//route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, {
    Name = "${var.env}-public-rt"
  })
}


//roue table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags, {
    Name = "${var.env}-private-rt"
  })
}


//public route to internet gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


//associate public subnet with route table
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


//elastic IP for NAT gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
}


//NAT gateway in public subnet
resource "aws_nat_gateway" "nat" {

  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = values(aws_subnet.public)[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name = "${var.env}-nat-gateway"
  })
}


//private route to NAT gateway
resource "aws_route" "private_nat_access" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}


//associate private subnet with route table
resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}