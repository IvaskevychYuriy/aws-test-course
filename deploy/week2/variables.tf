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

# this should match init-s3.sh
variable "s3_file_key" {
  default     = "week-2/hello.txt"
  description = "S3 file key"
}

variable "s3_file_version_id" {
  description = "S3 file version id"
}