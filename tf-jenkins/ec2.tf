
resource "aws_network_interface" "net_if" {
	subnet_id = var.subnet_id
  security_groups = [aws_security_group.jenkins-sg.id]
  tags = {
    "project"     = "ramp-up-devops"
    "responsible" = "brayan.ortiz"
  }
}

resource "aws_instance" "ctl-jenkins" {
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  key_name      = "rampup-devops-brayan.ortiz"

	user_data = base64encode(file("ansible/main.sh"))

  network_interface {
		network_interface_id = aws_network_interface.net_if.id
    device_index    = 0
  }

	tags = {
		"project" = "ramp-up-devops"
		"responsible" = "brayan.ortiz"
	}

	volume_tags = {
		"project" = "ramp-up-devops"
		"responsible" = "brayan.ortiz"
	}
}
