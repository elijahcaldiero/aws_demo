provider "aws" {
  profile = "default"
  region = "us-east-2"
}

variable "server_port" {
description = "The port the server will use for HTTP requests"
default = 80
}


resource "aws_launch_configuration" "test" {
  image_id = "ami-02ad6b83fd606d009"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
	      sudo yum -q -y install httpd git
              git clone https://github.com/elijahcaldiero/aws_demo.git
              sudo ln -s /home/centos/aws_demo/webapp /var/www/html
              sudo systemctl start httpd
              EOF

lifecycle {
  create_before_destroy = true
  }
}

output "elb_dns_name" {
  value = aws_elb.test.dns_name
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
 }

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "test" {
  launch_configuration = aws_launch_configuration.test.id
  availability_zones = data.aws_availability_zones.all.names

  load_balancers = [aws_elb.test.name]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-test"
    propagate_at_launch = true
  }
}

resource "aws_elb" "test" {
  name = "terraform-asg-test"
  availability_zones = data.aws_availability_zones.all.names
  security_groups = [aws_security_group.elb.id]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
#
#health_check {
#  healthy_threshold = 1
#  unhealthy_threshold = 600
#  timeout = 2
#  interval = 1
#  target = "HTTP:${var.server_port}/"
# }
}

resource "aws_security_group" "elb" {
  name = "terraform-test-elb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_db_instance" "testdb"{
#  allocated_storage = 5
#  engine = "mysql"
#  engine_version = "5.7"
#  instance_class = "db.t2.micro"
#  name = "demodb"
#  username = "demouser"
#  password = random_string.dbpass.result
#  skip_final_snapshot = true
#}
#
#resource "random_string" "dbpass"{
#  length = 16
#}
