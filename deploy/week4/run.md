## General:
If you change the default `aws.region` in `providers.tf` - make sure to also update `aws_subnet.availability_zone` (for both subnets) !

## Run TF:
- create variables file, e.g. `run.tfvars`
- ensure credentials are configured for AWS provider in `providers.tf`
- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform apply`

## Destory TF:
- `terraform apply -destroy`
