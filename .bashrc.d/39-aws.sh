#!/bin/bash

get_ec2_instance_id() {
    aws ec2 describe-instances \
        --profile instance-state-user \
        --filter "Name=tag:Name,Values=['$1']" \
        --query 'Reservations[*].Instances[*].[InstanceId]' \
        --output text
}
control_ec2() {
    aws ec2 "$1-instances" \
        --profile instance-state-user \
        --instance-ids $(get_ec2_instance_id "$2") \
        --output text
}
