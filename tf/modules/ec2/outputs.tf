output "public_ip" { 
    value = aws_instance.mongo_ec2.public_ip
}
output "instance_id" { 
    value = aws_instance.mongo_ec2.id
}
output "mongo_sg_id" { 
    value = aws_security_group.mongo_sg.id
}