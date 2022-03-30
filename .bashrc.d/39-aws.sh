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

# Log in with SSO-enabled AWS profile. Since we can't tell the aws tool which
# browser profile we want it to open the SSO prompt in, we manually open the
# URL using gco() defined in 37-browser.sh.
# Usage:
# sso_login <PROFILE> <BROWSER>
sso_login() {
    exec 3< <(aws sso login --profile "$1" --no-browser | tee /dev/tty)
    sleep 1
    gco -d "$HOME/.config/chrome-$2" -u $(grep -m 1 user_code <&3)
}
