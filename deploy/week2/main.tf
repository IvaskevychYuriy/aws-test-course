# EC2 itself
resource "aws_instance" "example_instance" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo aws s3api get-object --bucket ${var.s3_bucket_name} --key ${var.s3_file_key} --version-id ${var.s3_file_version_id} /dev/hello.txt
              EOF

  iam_instance_profile = aws_iam_instance_profile.example_instance_profile.name
  security_groups = [
    aws_security_group.example_sg.name
  ]
}

# SG to allow HTTP & SSH access
resource "aws_security_group" "example_sg" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # need to allow (all) outbound traffic so it can reach S3
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role to allow EC2 to access S3
resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "example_instance_profile"
  role = aws_iam_role.example_instance_role.name
}

resource "aws_iam_role" "example_instance_role" {
  name = "example_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_instance_policy" {
  # just allow everything
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.example_instance_role.name
}