variable "ports_sg" {
  type = map(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
    description = string
  }))
  default = {
    smtp = {
      from_port   = 25
      to_port     = 25
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "UnSecure SMTP access for Mail"
    }
    smtps = {
      from_port   = 465
      to_port     = 465
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Secure SMTP access for Mail"
    }
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "UnSecure HTTP access"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTPS access"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "SSH access"
    }
    k8s-cluster = {
      from_port   = 30000
      to_port     = 32767
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For K8s Cluster NodePort Services"
    }
    kube-api = {
      from_port   = 6443
      to_port     = 6443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For Kube-Api server"
    }
    kube-etcd = {
      from_port   = 2379
      to_port     = 2380
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For ETCD"
    }
    kubelet-api = {
      from_port   = 10250
      to_port     = 10250
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For kubelet-api"
    }
    kube-scheduler = {
      from_port   = 10259
      to_port     = 10259
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For kubelet-scheduler"
    }
    kube-controller-manager = {
      from_port   = 10257
      to_port     = 10257
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For kubelet-controller-manager"
    }
    app = {
      from_port   = 3000
      to_port     = 10000
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For Apps"
    }
    calico = {
      from_port   = 179
      to_port     = 179
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "For Calico"
    }
  }
}

######Naming and Tagging#########
variable "region" {
  default = "use2"
}

variable "project" {
  default = "DevSecOp"
}


variable "managed_by" {
  default = "terraform"
}

variable "owner" {
  default = "Gulnaz"
}

variable "k8s_cluster_vms" {
  type    = set(string)
  default = ["k8s-master", "k8s-worker-1", "k8s-worker-2"]
}



###### Ubuntu 24.04 Image ID ######
variable "ubuntu_ami" {
  default = "ami-0cb91c7de36eed2cb"
}