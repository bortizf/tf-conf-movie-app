# SG of presentation instances
resource "aws_security_group" "front-sg" {
  name        = "presentation-sg-brayan.ortiz"
  description = "Allow inbound traffic from alb and all outbound traffic"
  vpc_id      = data.aws_vpc.ramp-up-training.id

  ingress = [
    {
      cidr_blocks = null
      description = "Allow inbound traffic from alb sec. grp"
      from_port   = 3030
      protocol    = "TCP"
      to_port     = 3030
      ipv6_cidr_blocks = null
      self = null
      security_groups = [ aws_security_group.lb-sg.id ]
      prefix_list_ids = null
    }, 

    {
      cidr_blocks = [ "67.73.245.211/32" ]
      description = "Allow ssh from my machines"
      from_port   = 22
      protocol    = "TCP"
      to_port     = 22
      ipv6_cidr_blocks = null
      self = null
      security_groups = null
      prefix_list_ids = null
    },
  ]

  egress = [
    {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow all outbound"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      ipv6_cidr_blocks = null
      self = null
      security_groups = null
      prefix_list_ids = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

# SG of logic instances
resource "aws_security_group" "back-sg" {
  name        = "logic-sg-brayan.ortiz"
  description = "Allow inbound traffic from internal alb and all outbound traffic"
  vpc_id      = data.aws_vpc.ramp-up-training.id

  ingress = [
    {
      cidr_blocks = null
      description = "Allow inbound traffic from alb sec. grp"
      from_port   = 3000
      protocol    = "TCP"
      to_port     = 3000
      ipv6_cidr_blocks = null
      self = null
      security_groups = [ aws_security_group.lb-sg-int.id ]
      prefix_list_ids = null
    }, 

    {
      cidr_blocks = [data.aws_vpc.ramp-up-training.cidr_block]
      description = "Allow ssh from instances in the same VPC"
      from_port   = 22
      protocol    = "TCP"
      to_port     = 22
      ipv6_cidr_blocks = null
      self = null
      security_groups = null
      prefix_list_ids = null
    },
  ]

  egress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      ipv6_cidr_blocks = null
      self = null
      security_groups = null
      prefix_list_ids = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

# SG of internal ALB
resource "aws_security_group" "lb-sg-int" {
  name        = "movie-back-lb-sg-brayan.ortiz"
  description = "Allow HTTP inbound traffic from the external ALB and all outbound traffic"
  vpc_id      = data.aws_vpc.ramp-up-training.id

  ingress = [
    {
      cidr_blocks = ["10.1.8.0/21"]
      description = "HTTP from public-1 subnets"
      from_port   = 3000
      protocol    =  "TCP"
      to_port     =  3000
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    },
    {
      cidr_blocks = ["10.1.0.0/21"]
      description = "HTTP from public-0 subnet"
      from_port   = 3000
      protocol    =  "TCP"
      to_port     = 3000
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    },
    {
      cidr_blocks = [data.aws_vpc.ramp-up-training.cidr_block]
      description = "HTTP from public-0 subnet"
      from_port   = -1
      protocol    =  "ICMP"
      to_port     =  -1
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  egress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

# SG of external ALB
resource "aws_security_group" "lb-sg" {
  name        = "movie-front-lb-sg-brayan.ortiz"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.ramp-up-training.id

  ingress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP from Internet"
      from_port   = 80
      protocol    =  "TCP"
      to_port     =  80
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  egress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "movie-data-rds-sg-brayan.ortiz"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.ramp-up-training.id

  ingress = [
    {
      cidr_blocks = [ "10.1.88.0/21" ]
      description = "HTTP from private-0 subnet"
      from_port   = 3306
      protocol    =  "TCP"
      to_port     =  3306
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    },
    {
      cidr_blocks = [ "10.1.80.0/21" ]
      description = "HTTP from private-0 subnet"
      from_port   = 3306
      protocol    =  "TCP"
      to_port     =  3306
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  egress = [
    {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      ipv6_cidr_blocks = null
      prefix_list_ids = null
      self = null
      security_groups = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}