provider aws {
  region = var.region
  profile = var.profile
}

provider aws {
  region = "us-east-1"
  profile = var.profile
  alias = "us-east-1"
}

# create a bucket to hold the state file
terraform {
  backend "s3" {
    bucket = local.project
    key = "tfstate" # is the terraform 'state'
    region = var.region
  }
}