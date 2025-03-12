resource "aws_instance" "monitor" {
  ami                    = var.ubuntu_ami
  vpc_security_group_ids = [aws_security_group.monitor_sg.id]
  instance_type          = "t2.medium"
  key_name               = "DevSecOpProjectKeyPair"
  user_data              = file("./extras/monitor.sh")

  root_block_device {
    volume_size = 10
    volume_type = "gp2"
  }

  tags = merge(
    { Name = format(local.Name, "monitor") },
    local.common_tags
  )
}

##### SG for Monitoring App ######
resource "aws_security_group" "monitor_sg" {
  name        = format(local.Name, "monitor-sg")
  description = "This SG for monitoring tool"
  vpc_id      = data.aws_vpc.default.id
  tags = merge(
    { Name = format(local.Name, "monitor-sg") },
    local.common_tags
  )
}


#### SG Ingress Rules ######
resource "aws_vpc_security_group_ingress_rule" "monitor_ingress_rules" {
  security_group_id = aws_security_group.monitor_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9090
  ip_protocol       = "tcp"
  to_port           = 9090
}

resource "aws_vpc_security_group_ingress_rule" "monitor_ingress_grafana" {
  security_group_id = aws_security_group.monitor_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "monitor_ingress_blackb_ex" {
  security_group_id = aws_security_group.monitor_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 9115
  ip_protocol       = "tcp"
  to_port           = 9115
}

resource "aws_vpc_security_group_ingress_rule" "monitor_ingress_ssh" {
  security_group_id = aws_security_group.monitor_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}



#### Monitor SG Engress Rules ######
resource "aws_vpc_security_group_egress_rule" "monitor_all_open" {
  security_group_id = aws_security_group.monitor_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = {
    Name = "${var.project}-monitor-engress"
  }
}
