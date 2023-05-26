output "ec2_ip_address" {
  value = aws_instance.my_instance.public_ip
}

output "sns_topic_arn" {
  value = aws_sns_topic.my_topic.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.my_queue.id
}