terraform {
  backend "s3" {
    bucket = "terraform-state-vfreitas-clc16-533267340601-us-east-1-an"
    key    = "terraform/state"
    region = "us-east-1"
  use_lockfile = true
    encrypt = true
  }
}
