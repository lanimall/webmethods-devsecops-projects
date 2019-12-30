#!/usr/bin/env bash

# Log everything we do.
set -x
exec > /var/log/user-data.log 2>&1

mkdir -p /etc/aws/
cat > /etc/aws/aws.conf <<- EOF
[Global]
Zone = ${availability_zone}
EOF

# Create initial logs config.
cat > ./awslogs.conf << EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
log_stream_name = bastion-{instance_id}
log_group_name = /var/log/messages
file = /var/log/messages
datetime_format = %b %d %H:%M:%S
buffer_duration = 5000
initial_position = start_of_file

[/var/log/user-data.log]
log_stream_name = bastion-{instance_id}
log_group_name = /var/log/user-data.log
file = /var/log/user-data.log
EOF

##not doing anything...more a placeholder if needed.