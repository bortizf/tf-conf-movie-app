# ASG of front instances
resource "aws_autoscaling_group" "front-asg" {
  name             = "movie-front-asg-brayan.ortiz"
  max_size         = 2
  min_size         = 1
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.front-lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_attachment" "front-asg" {
  autoscaling_group_name = aws_autoscaling_group.front-asg.id
  alb_target_group_arn   = aws_lb_target_group.front-lb.arn

  depends_on = [
	aws_lb_target_group.front-lb,
	aws_autoscaling_group.front-asg
  ]
}

# ASG of back instances
resource "aws_autoscaling_group" "back-asg" {
  name             = "movie-back-asg-brayan.ortiz"
  max_size         = 2
  min_size         = 1
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.back-lt.id
    version = "$Latest"
  }
}

# Attach it to an ALB
resource "aws_autoscaling_attachment" "back-asg" {
  autoscaling_group_name = aws_autoscaling_group.back-asg.id
  alb_target_group_arn   = aws_lb_target_group.back-lb.arn

  depends_on = [
	aws_lb_target_group.back-lb,
	aws_autoscaling_group.back-asg
  ]
}
