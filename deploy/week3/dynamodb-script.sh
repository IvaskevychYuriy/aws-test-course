#!/bin/bash

region=us-west-2
table_name=example_table

aws dynamodb list-tables --region $region

aws dynamodb put-item --table-name $table_name --item '{ "Id": { "N": "1" }, "Name": { "S": "Hello World" } }' --region $region

aws dynamodb get-item --table-name $table_name --key '{ "Id": { "N": "1" } }' --region $region

# keep the window open
read dummy