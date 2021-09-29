resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-ctl-sg-brayan.ortiz"
  description = "Allow all traffic from port 8080 and 22 from my machine"
  vpc_id      = var.vpc_id

  ingress = [
    {
      cidr_blocks      = ["67.73.245.211/32"]
      description      = "Allow ssh from my machines"
      from_port        = 22
      protocol         = "TCP"
      to_port          = 22
      ipv6_cidr_blocks = null
      self             = null
      security_groups  = null
      prefix_list_ids  = null
    },
    {
      cidr_blocks      = ["67.73.245.211/32"]
      description      = "Access Jenkins port from my machines"
      from_port        = 8080
      protocol         = "TCP"
      to_port          = 8080
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      self             = null
      security_groups  = null
    }
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow all traffic"
      from_port        = 0
      protocol         = "-1"
      to_port          = 0
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      self             = null
      security_groups  = null
    }
  ]

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}
