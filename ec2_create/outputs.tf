#to get the public ip of the created instance
output "ec2_public_ip" {
    value = aws_instance.ec2_create.public_ip
}