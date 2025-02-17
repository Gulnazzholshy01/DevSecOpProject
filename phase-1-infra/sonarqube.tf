resource "aws_instance" "sonarqube" {
  ami                    = var.ubuntu_ami
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  instance_type          = "t2.medium"
  key_name               = "DevSecOpProjectKeyPair"
  user_data              = file("./extras/nexus-sonarqube.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = merge(
    { Name = format(local.Name, "sonarqube") },
    local.common_tags
  )
}