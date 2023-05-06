output "public_ip" {
  value       = aws_instance.example_instance.public_ip
  description = "EC2 instance public IP"
}

output "rds_endpoint" {
  value       = aws_db_instance.example_rds.endpoint
  description = "RDS instance endpoint"
}