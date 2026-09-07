#! bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0e17db6ab1dfaa76a"
DOMAIN="rakesh.bond"
ZONE_ID="Z020801033VIO4NL0L0YA"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
            --image-id $AMI_ID \
            --instance-type t3.micro \
            --security-group-ids $SG_ID \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
            --query 'Instances[0].InstanceId' \
            --output text)

    if [ $instance == "frontend" ]; then
     IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text)
     RECORD_NAME=$DOMAIN #rakesh.bond
    else
      IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
     RECORD_NAME="$instance.$DOMAIN" #mongodb.rakesh.bond
    fi

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    {
    "Comment": "Creating a new A record",
    "Changes": [
        {
        "Action": "CREATE",
        "ResourceRecordSet": {
            "Name": $DOMAIN,
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [
            {
                "Value": $IP
            }
            ]
        }
        }
    ]
    }
done
