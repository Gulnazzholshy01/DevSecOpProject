###### Get a default VPC ID ######
data "aws_vpc" "default" {
  default = true
}

###### User data script ######
data "template_file" "user_data" {
  for_each = var.k8s_cluster_vms
  template = file("./extras/k8s-initial-setup.tpl")
  vars = {
    hostname = each.key
    crio_version = "v1.32" 
    crictl_version = "v1.32.0"
    kubernetes_version = "v1.32"
    k8s_cluster_version = "1.32.0-1.1"
  }
}