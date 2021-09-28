variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  type    = string
  default = "us-west-1"
}

variable "DB_USER" {}
variable "DB_PASS" {}

variable "PATH_TO_PRIVATE_KEY" {}

variable "INSTANCE_USERNAME" {
  type    = string
  default = "ubuntu"
}

variable "subnet_id" {
	type		= string
	default = "subnet-0088df5de3a4fe490"
}

variable "subnets" {
  default = {
    "public" = ["subnet-0088df5de3a4fe490", "subnet-055c41fce697f9cca"]
    "private" = ["subnet-0d74b59773148d704", "subnet-038fa9d9a69d6561e"]
  }
}

variable "resources" {
  type = list(string)
  default = ["instance", "volume"]
}

variable "vpc_id" {
  type = string
  default = "vpc-0d2831659ef89870c"
}