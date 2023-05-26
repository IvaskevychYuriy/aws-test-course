resource "aws_sqs_queue" "my_queue" {
  name                       = "my-queue"
  receive_wait_time_seconds  = 10
  visibility_timeout_seconds = 30
}

resource "aws_sns_topic" "my_topic" {
  name = "my-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "email"
  endpoint  = var.target_email
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  queue_url = aws_sqs_queue.my_queue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Allow-SNS-SendMessage",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.my_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.my_topic.arn}"
        }
      }
    }
  ]
}
EOF
}

resource "aws_security_group" "my_security_group" {
  name = "my-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_iam_policy" "ec2_policy" {
  name   = "ec2-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:*",
        "sns:*"
      ],
      "Resource": [
        "${aws_sqs_queue.my_queue.arn}",
        "${aws_sns_topic.my_topic.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "example_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_instance" "my_instance" {
  ami           = var.image_id
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups      = [aws_security_group.my_security_group.name]
  iam_instance_profile = aws_iam_instance_profile.example_instance_profile.name
}
