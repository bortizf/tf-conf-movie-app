# lt for front instances
resource "aws_launch_template" "front-lt" {
  name = "movie-front-lt-brayanortiz"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.front-sg.id]
    subnet_id                   = var.subnets["public"][0]

    device_index = 0
  }

  key_name      = "rampup-devops-brayan.ortiz"
  instance_type = "t2.micro"
  image_id      = "ami-0d382e80be7ffdae5"
  user_data = base64encode(templatefile("ansible/ui/main.tpl", {
    lb-int-dns = "${aws_lb.back-lb.dns_name}"
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      "project"     = "ramp-up-devops"
      "responsible" = "brayan.ortiz"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      "project"     = "ramp-up-devops"
      "responsible" = "brayan.ortiz"
    }
  }

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }

  depends_on = [
    aws_lb.back-lb,
    aws_security_group.front-sg
  ]
}

# lt for back instances
resource "aws_launch_template" "back-lt" {
  name = "movie-back-lt-brayanortiz"

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }

  network_interfaces {
    security_groups = [aws_security_group.back-sg.id]
    subnet_id       = var.subnets["private"][0]

    device_index = 0
  }

  key_name      = "rampup-devops-brayan.ortiz"
  instance_type = "t2.micro"
  image_id      = "ami-0d382e80be7ffdae5"
  user_data = base64encode(templatefile("ansible/api/main.tpl", {
    db_host = "${aws_db_instance.db.address}"
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      "project"     = "ramp-up-devops"
      "responsible" = "brayan.ortiz"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      "project"     = "ramp-up-devops"
      "responsible" = "brayan.ortiz"
    }
  }

  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }

  depends_on = [
    aws_db_instance.db,
    aws_security_group.back-sg
  ]
}
