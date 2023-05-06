# EC2 itself
resource "aws_instance" "example_instance" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo aws s3api get-object --bucket ${var.s3_bucket_name} --key week-3/dynamodb-script.sh /dev/dynamodb-script.sh
              sudo chmod +x /dev/dynamodb-script.sh
              sudo aws s3api get-object --bucket ${var.s3_bucket_name} --key week-3/rds-script.sql /dev/rds-script.sql
              sudo chmod +x /dev/rds-script.sql

              sudo dnf install postgresql15 -y
              EOF

  iam_instance_profile = aws_iam_instance_profile.example_instance_profile.name
  security_groups = [
    aws_security_group.example_sg.name
  ]
}

# SG to allow HTTP, SSH, RDS PG and outside (for S3) access
resource "aws_security_group" "example_sg" {
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Amazon RDS with PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
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

# SG to RDS PG access
resource "aws_security_group" "example_rds_sg" {
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role to allow EC2 to access S3 and DynamoDB
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

resource "aws_iam_role_policy_attachment" "example_instance_policy_s3" {
  # allow full access to S3
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.example_instance_role.name
}

resource "aws_iam_role_policy_attachment" "example_instance_policy_dynamodb" {
  # allow full access to DynamoDB
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.example_instance_role.name
}

# RDS with Postgres
resource "aws_db_instance" "example_rds" {
  identifier           = "example-postgres-db"
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = var.db_instance_class
  allocated_storage    = 5
  db_name              = "example_db"
  username             = "testadmin"
  password             = var.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true
  publicly_accessible  = true
  multi_az             = false
  vpc_security_group_ids = [
    aws_security_group.example_rds_sg.id
  ]
}

# DynamoDB
resource "aws_dynamodb_table" "example_dynamodb" {
  name           = "example_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Id"
  attribute {
    name = "Id"
    type = "N"
  }
}