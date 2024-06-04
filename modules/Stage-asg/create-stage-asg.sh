#!/bin/bash

# Variables
LAUNCH_TEMPLATE_NAME="my-launch-template"
LAUNCH_TEMPLATE_VERSION="1"
AUTO_SCALING_GROUP_NAME="my-auto-scaling-group"
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-pair-name"
SECURITY_GROUP="sg-xxxxxxxx"
AMI_ID="ami-xxxxxxxx" # Amazon Linux 2 AMI ID, change as needed
SUBNETS="subnet-xxxxxxxx,subnet-yyyyyyyy"

# Create a Launch Template
aws ec2 create-launch-template --launch-template-name $LAUNCH_TEMPLATE_NAME \
    --version-description "Version $LAUNCH_TEMPLATE_VERSION" \
    --launch-template-data "{
        \"ImageId\": \"$AMI_ID\",
        \"InstanceType\": \"$INSTANCE_TYPE\",
        \"KeyName\": \"$KEY_NAME\",
        \"SecurityGroupIds\": [\"$SECURITY_GROUP\"]
    }"

# Create an Auto Scaling Group
aws autoscaling create-auto-scaling-group --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --launch-template "LaunchTemplateName=$LAUNCH_TEMPLATE_NAME,Version=$LAUNCH_TEMPLATE_VERSION" \
    --min-size 1 --max-size 3 --desired-capacity 2 \
    --vpc-zone-identifier "$SUBNETS"

# Set Auto Scaling Policies (optional)
aws autoscaling put-scaling-policy --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --policy-name "scale-out" \
    --scaling-adjustment 1 --adjustment-type "ChangeInCapacity"

aws autoscaling put-scaling-policy --auto-scaling-group-name $AUTO_SCALING_GROUP_NAME \
    --policy-name "scale-in" \
    --scaling-adjustment -1 --adjustment-type "ChangeInCapacity"

echo "Auto Scaling Group and policies created successfully!"



# chmod +x create-asg.sh
# ./create-asg.sh
