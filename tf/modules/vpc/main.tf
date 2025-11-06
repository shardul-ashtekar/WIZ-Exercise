resource "aws_vpc" "shar-vpc" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Internet Gateway
resource "aws_internet_gateway" "shar-igw" {
  vpc_id = aws_vpc.shar-vpc.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# Public subnets
resource "aws_subnet" "shar-pub-sub" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.shar-vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-${count.index}"
  })
}

# Private subnets
resource "aws_subnet" "shar-priv-sub" {
  count      = length(var.private_subnets)
  vpc_id     = aws_vpc.shar-vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-${count.index}"
  })
}

# Public route table and route to IGW
resource "aws_route_table" "shar-pub-rt" {
  vpc_id = aws_vpc.shar-vpc.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-public-rt" })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.shar-pub-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.shar-igw.id
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.shar-pub-sub)
  subnet_id      = aws_subnet.shar-pub-sub[count.index].id
  route_table_id = aws_route_table.shar-pub-rt.id
}

# Private route table
resource "aws_route_table" "shar-pri-rt" {
  vpc_id = aws_vpc.shar-vpc.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-private-rt" })
}

# Associate private route table to private subnets
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.shar-priv-sub)
  subnet_id      = aws_subnet.shar-priv-sub[count.index].id
  route_table_id = aws_route_table.shar-pri-rt.id
}

# Allocate Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "${var.name_prefix}-nat-eip" })
}

# Create NAT Gateway in first public subnet
resource "aws_nat_gateway" "shar-nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.shar-pub-sub[0].id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat" })
}

# Add route to NAT in private route table
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.shar-pri-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.shar-nat.id
}
