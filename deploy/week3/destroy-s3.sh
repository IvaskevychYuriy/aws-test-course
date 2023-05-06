#!/bin/bash

# variables must match with 'init-s3.sh'

# empty & destroy s3
bucket_name=sadfw3r2dasawd
aws s3 rm s3://$bucket_name --recursive
aws s3api delete-bucket --bucket $bucket_name --region us-west-2

# keep the window open
read dummy