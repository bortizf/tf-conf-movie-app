provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

data "aws_vpc" "ramp-up-training" {
  id = var.vpc_id
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ramp-up-training.id]
  }
}

data "aws_subnet" "public" {
	id = [for id in data.aws_subnets.all.ids : id if id == var.subnet_id][0]
}
