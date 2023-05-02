
## Init S3:
- (In VS Code from 'week2' folder): `.\init-s3.sh`

## Run TF:
- create variables file, e.g. `run.tfvars`
- ensure credentials are configured for AWS provider in `providers.tf`
- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan -var-file="run.tfvars"`
- `terraform apply -var-file="run.tfvars"`

## Check file:
- SSH into EC2 instance
- `cat /dev/hello.txt`

## Destory TF:
- `terraform apply -destroy -var-file="run.tfvars"`

**NOTE:** don't forget to delete the S3 bucket!