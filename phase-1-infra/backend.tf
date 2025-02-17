terraform {
  backend "s3" {
    bucket       = "my-awesome-projects-backend"
    key          = "devsecop-project-1/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}