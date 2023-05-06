#!/bin/bash

# variables must match with 'destroy-s3.sh'

# push to s3
bucket_name=sadfw3r2dasawd
aws s3api create-bucket --bucket $bucket_name --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-object --bucket $bucket_name --key week-3/dynamodb-script.sh --body ./dynamodb-script.sh
aws s3api put-object --bucket $bucket_name --key week-3/rds-script.sql --body ./rds-script.sql

# keep the window open
read dummy