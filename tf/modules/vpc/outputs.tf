output "vpc_id" { 
    value = aws_vpc.shar-vpc.id 
}
output "public_subnets" { 
    value = aws_subnet.shar-pub-sub[*].id 
}
output "private_subnets" { 
    value = aws_subnet.shar-priv-sub[*].id
}
output "igw_id" { 
    value = aws_internet_gateway.shar-igw.id 
}
