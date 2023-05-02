output "public_ip" {
  value       = aws_instance.example_instance.public_ip
  description = "EC2 instance public IP"
}