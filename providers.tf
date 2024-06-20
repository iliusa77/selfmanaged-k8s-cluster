terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7"
    }
  }
}

provider "aws" {
  profile    = "${var.profile}"
  region     = "${var.region}"    
}
data "aws_availability_zones" "azs" {
    state = "available"
}



