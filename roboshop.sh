#! bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0e17db6ab1dfaa76a"

for instance in $@
do
    aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids SG_ID \
        --tag-specifications 'ResourceType=$instance,Tags=[{Key=Name,Value=$instance}]' \
        --query 'Instances[0].PrivateIpAddress' \
        --output text
done