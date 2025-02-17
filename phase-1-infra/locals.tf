locals {
  common_tags = {
    Project   = var.project
    ManagedBy = var.managed_by
    Owner     = var.owner
  }

}

locals {
  Name = "${var.project}-%s"
}