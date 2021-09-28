# External-facing load balancer
resource "aws_lb" "front-lb" {
  name = "movie-front-lb-brayanortiz"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lb-sg.id ]
	subnets = var.subnets["public"]

  tags = {
    "project" = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

resource "aws_lb_target_group" "front-lb" {
  name = "movie-front-tg-brayanortiz"
  port = "3030"
  protocol = "HTTP"
  vpc_id = data.aws_vpc.ramp-up-training.id
}

resource "aws_lb_listener" "front-lb" {
  load_balancer_arn = aws_lb.front-lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front-lb.arn
  }
}

# Internal load balancer
resource "aws_lb" "back-lb" {
  name = "movie-back-lb-brayanortiz"
  internal = true
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lb-sg-int.id ]
	subnets = var.subnets["private"]

  tags = {
    "project" = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

resource "aws_lb_target_group" "back-lb" {
  name = "movie-back-tg-brayanortiz"
  port = "3000"
  protocol = "HTTP"
  vpc_id = data.aws_vpc.ramp-up-training.id
}

resource "aws_lb_listener" "back-lb" {
  load_balancer_arn = aws_lb.back-lb.arn
  port = "3000"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.back-lb.arn
  }

  depends_on = [
    aws_lb.back-lb,
    aws_lb_target_group.back-lb
  ]
}