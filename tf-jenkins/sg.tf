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
      cidr_blocks      = ["67.73.245.211/32", "192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20"]
      description      = "Access Jenkins port from my machines and open github webhooks"
      from_port        = 8080
      protocol         = "TCP"
      to_port          = 8080
      ipv6_cidr_blocks = ["2a0a:a440::/29", "2606:50c0::/32"]
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
