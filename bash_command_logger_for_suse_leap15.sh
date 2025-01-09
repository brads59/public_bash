#!/bin/bash
# Simple script to log all bash output to a file. No guarantee is expressed or implied. Also assumes rsyslog is running not syslog-ng
set -e

# Check for openSUSE Leap 15.x
if ! grep -q "openSUSE Leap 15" /etc/os-release; then
    echo "Error: This script is designed for openSUSE Leap 15.x only."
    exit 1
fi

#Check for rsyslog
if ! command -v rsyslogd &> /dev/null; then
    echo "rsyslog is not installed. exiting"
    exit 1
fi


# Update /etc/bash.bashrc for global logging
echo "Updating /etc/bash.bashrc for command logging..."
cat << 'EOF' >> /etc/bash.bashrc

# Global command logging for all users
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000

# Log all commands to /var/log/commands.log using the local1 facility
export PROMPT_COMMAND='logger -p local1.notice -t bash_command "$(whoami)@$(hostname):$(pwd): $(history 1 | sed "s/^ *[0-9]* *//")"'
EOF

# Configure rsyslog for logging to /var/log/commands.log
echo "Configuring rsyslog to log commands..."
cat << 'EOF' > /etc/rsyslog.d/bash_command.conf
local1.*    /var/log/commands.log
EOF

# Restart rsyslog service
echo "Restarting rsyslog service..."
systemctl restart rsyslog

# Secure the log file
echo "Setting permissions on /var/log/commands.log..."
touch /var/log/commands.log
chmod 600 /var/log/commands.log
chown root:root /var/log/commands.log

# Confirmation message
echo "Command logging setup complete! All commands will be logged to /var/log/commands.log."
