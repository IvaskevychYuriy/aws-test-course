resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a" # should match with the region!
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b" # should match with the region!
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_instance" "public_ec2" {
  ami                         = var.image_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              
              sudo su
              yum update -y
              yum install httpd -y
              service httpd start
              chkconfig httpd on
              cd /var/www/html
              echo "<html><h1>Public</h1></html>" > index.html
              EOF
}

resource "aws_security_group" "public_ec2_sg" {
  name        = "public-ec2-sg"
  description = "Security group for public EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "private_ec2" {
  ami             = var.image_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.private_ec2_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              
              sudo su
              yum update -y
              yum install httpd -y
              service httpd start
              chkconfig httpd on
              cd /var/www/html
              echo '<html><h1>Private</h1><iframe width="420" height="315" src="https://www.youtube.com/embed/E4WlUXrJgy4?autoplay=1&mute=1" allow="autoplay"></iframe></html>' > index.html
              EOF
}

resource "aws_security_group" "private_ec2_sg" {
  name        = "private-ec2-sg"
  description = "Security group for private EC2 instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat_ec2" {
  ami               = "ami-08e2742915c5be5e2" # AMI of some NAT EC2
  instance_type     = var.instance_type
  subnet_id         = aws_subnet.public_subnet.id
  security_groups   = [aws_security_group.public_ec2_sg.id]
  source_dest_check = false
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat_ec2.id
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_default_route_table.default_route_table.id
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
  health_check {
    protocol            = "HTTP"
    path                = "/index.html"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group_attachment" "public_ec2_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.public_ec2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "private_ec2_attachment" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.private_ec2.id
  port             = 80
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  subnets            = concat(aws_subnet.public_subnet.*.id, aws_subnet.private_subnet.*.id)
  security_groups    = [aws_security_group.public_ec2_sg.id]
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}