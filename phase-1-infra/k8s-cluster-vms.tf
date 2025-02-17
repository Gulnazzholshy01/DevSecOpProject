resource "aws_instance" "k8s_cluster" {
  for_each               = var.k8s_cluster_vms
  ami                    = var.ubuntu_ami
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  instance_type          = "t2.medium"
  key_name               = "DevSecOpProjectKeyPair"
  user_data              = base64encode(data.template_file.user_data[each.key].rendered)

  root_block_device {
    volume_size = 25
    volume_type = "gp2"
  }

  tags = merge(
    { Name = format(local.Name, "${each.key}") },
    local.common_tags
  )
}

