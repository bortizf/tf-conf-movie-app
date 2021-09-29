variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable "AWS_REGION" {
	type = string
	default = "us-west-1"
}

variable "subnet_id" {
	type = string
	default = "subnet-0088df5de3a4fe490"
}

variable "vpc_id" {
  type = string
  default = "vpc-0d2831659ef89870c"
}