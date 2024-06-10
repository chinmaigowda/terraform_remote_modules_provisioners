#to execute a local command and hence remote connection is not needed
resource "null_resource" "local-exec" {
  provisioner "local-exec" {
    command = var.local_exec_command
  }
}