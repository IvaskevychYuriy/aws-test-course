variable "image_id" {
  default     = "ami-0747e613a2a1ff483"
  description = "EC2 image ID"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  description = "EC2 key pair name"
}

# this should match init-s3.sh
variable "s3_bucket_name" {
  default     = "sadfw3r2dasawd"
  description = "S3 bucket name"
}

variable "db_instance_class" {
  description = "The RDS instance class to use"
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "The password for the RDS instance"
}