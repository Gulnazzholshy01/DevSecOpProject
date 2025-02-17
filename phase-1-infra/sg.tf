##### SG for DevSecOp Project ######
resource "aws_security_group" "my_sg" {
  name        = format(local.Name, "sg")
  description = "This SG for DevSecOp Project"
  vpc_id      = data.aws_vpc.default.id
  tags = merge(
    { Name = format(local.Name, "sg") },
    local.common_tags
  )
}


##### SG Ingress Rules ######
resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each          = var.ports_sg
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
  tags = {
    Name = "${var.project}-${each.key}-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_ip_in_ip" {
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = 4
  tags = {
    Name = "${var.project}_ip_in_ip_ingress"
  }
}


##### SG Engress Rules ######
resource "aws_vpc_security_group_egress_rule" "all_open" {
  security_group_id = aws_security_group.my_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = {
    Name = "${var.project}-engress"
  }
}
