#!/bin/bash

# create a file
file_path=/tmp/hello.txt
echo "Hello World" > $file_path
echo "File contents of '$file_path':"
cat $file_path

# push it to s3
bucket_name=sadfw3r2dasawd
aws s3api create-bucket --bucket $bucket_name --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
aws s3api put-bucket-versioning --bucket $bucket_name --versioning-configuration Status=Enabled
aws s3api put-object --bucket $bucket_name --key week-2/hello.txt --body $file_path
aws s3api put-public-access-block --bucket $bucket_name --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# keep the window open
read dummy