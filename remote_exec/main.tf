data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    owners = ["099720109477"]  #cannonical user or ["amazon"]
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#to specify the type of the pem key (search terraform create pem file) as we should not hard code the pem key
resource "tls_private_key" "rsa_pem_key_type" {
    algorithm = "RSA"
    rsa_bits  = 4096
}
#to create pem key for instance (search terraform aws pem key) using key type which saves public key in .authorized_keys folder in ubuntu
resource "aws_key_pair" "rsa_pem_key_create" {
    key_name   = var.rsa_pem_key_name
    public_key = tls_private_key.rsa_pem_key_type.public_key_openssh  #as we need public key only (go to aws console and see while creating rsa key it says openssh)
}
#to save the downloaded private pem key file in a default file (search terraform local file)
resource "local_file" "pem_key_file" {
  content  = tls_private_key.rsa_pem_key_type.private_key_openssh  #to save the private key generated
  filename = var.saved_key_path
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#to create a security group with ssh port 22 access
resource "aws_security_group" "allow_ssh" {
    name = var.security_group_name

}
#to create inbound traffic - ingress
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
#to create outbound traffic - egress
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#to create an aws instance using the output of ami id in data block
resource "aws_instance" "ec2_create" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.ec2_instance_type
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]  #to mention the list of security groups if there are more than one
    key_name = aws_key_pair.rsa_pem_key_create.key_name  # calling the created pem key
    tags = {
        Name = "Terraform_ec2"
  }
}
