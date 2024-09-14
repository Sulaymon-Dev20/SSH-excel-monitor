#!/bin/bash

# Path to the log file 📁
LOG_FILE="/etc/ssh/backup_scripts/ssh_access.json"

# Ensure the log file exists and initialize with an empty array if it doesn't 🛠️
if [ ! -f "$LOG_FILE" ]; then
    echo "[" > "$LOG_FILE"
else
    # Remove the last line (closing bracket) temporarily to append new entries 📝
    sed -i '$d' "$LOG_FILE"
fi

# Get current timestamp ⏰
TIME=$(date +"%Y-%m-%d %T")

# Get SSH client IP address and PID 📍
CLIENT_IP="$SSH_CLIENT"
PID=$$

# Get SSH connection details 🌐
SSH_CONNECTION_DETAILS=$(echo "$SSH_CONNECTION" | awk '{print "{ \"remote_ip\": \"" $1 "\", \"remote_port\": \"" $2 "\", \"local_ip\": \"" $3 "\", \"local_port\": \"" $4 "\" }" }')

# Get SSH username 👤
SSH_USER="$USER"

# Check if the command is SCP or SFTP 🔍
if [[ "$SSH_ORIGINAL_COMMAND" =~ ^scp || "$SSH_ORIGINAL_COMMAND" =~ ^sftp ]]; then
    LOG_ENTRY="{ \"time\": \"$TIME\", \"client_ip\": \"$CLIENT_IP\", \"ssh_connection\": \"SCP/SFTP\", \"ssh_user\": \"$SSH_USER\", \"pid\": \"$PID\", \"active\": true }"
else
    # Construct JSON object for SSH connection with 'active' set to true 📝
    LOG_ENTRY="{ \"time\": \"$TIME\", \"client_ip\": \"$CLIENT_IP\", \"ssh_connection\": $SSH_CONNECTION_DETAILS, \"ssh_user\": \"$SSH_USER\", \"pid\": \"$PID\", \"active\": true }"
fi

# Check if the log file is empty (excluding the opening bracket) 🗂️
if [ "$(wc -l < "$LOG_FILE")" -eq 1 ]; then
    echo "$LOG_ENTRY" >> "$LOG_FILE"
else
    echo ",$LOG_ENTRY" >> "$LOG_FILE"
fi

# Add closing bracket for array at the end of the file 🏁
echo "]" >> "$LOG_FILE"

# Execute the original SSH command or fallback to the default shell 🔄
if [[ $SSH_ORIGINAL_COMMAND ]]; then
    eval "$SSH_ORIGINAL_COMMAND"
else
    $SHELL
fi
