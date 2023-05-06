
## Init S3:
- `.\init-s3.sh`

## Run TF:
- create variables file, e.g. `run.tfvars`
- ensure credentials are configured for AWS provider in `providers.tf`
- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan -var-file="run.tfvars"`
- `terraform apply -var-file="run.tfvars"`

## Verify:
- SSH into EC2 instance
- `/dev/dynamodb-script.sh` to verify DynamoDB
- `psql --host=<INSTANCE_HOST> --port=5432 --username=testadmin --password --dbname=postgres -f /dev/rds-scipt.sql` to verify RDS with Postgres (Note: you will be prompted a password)

## Destory TF:
- `terraform apply -destroy -var-file="run.tfvars"`

## Destory S3:
- `.\destroy-s3.sh`

**NOTE:** don't forget to delete the S3 bucket!