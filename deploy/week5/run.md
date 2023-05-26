## General:
If you change the default `aws.region` in `providers.tf` - make sure to also use the same below in verification steps!

## Run TF:
- create variables file, e.g. `run.tfvars`
- ensure credentials are configured for AWS provider in `providers.tf`
- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform apply -var-file="run.tfvars"`. Note that this will create a subscritpion for a provided variable

## Verify:
- Confirm email subscription
- SSH into EC2 instance
- `aws sns publish --topic <sns_topic_arn> --message 'hello there' --region us-west-2` and then check email
- `aws sqs send-message --queue-url <sqs_queue_url> --message-body 'hello there' --region us-west-2`
- `aws sqs receive-message --queue-url <sqs_queue_url> --region us-west-2`

## Destory TF:
- `terraform apply -destroy -var-file="run.tfvars"`