#to connect to server "ssh -i private.pem user@public_ip"
resource "null_resource" "file" {
  connection {
    type = "ssh"  #for ssh
    user = var.user_name  #for user@ip
    agent = false      # whenever we do ssh from local it will ask to save the user so to avoid that agent is false
    host = var.ec2_public_ip  #to get the public ip
    private_key = file(var.ec2_pem_path)   #to load the content of private pem key file to this private key argument file(path) is used
  }
  provisioner "file" {
    source = var.source_file_path
    destination = var.destination_file_path
  }
}