#!/bin/bash

# Path to your JSON file 📁
JSON_FILE="/etc/ssh/backup_scripts/ssh_access.json"
TEMP_JSON_FILE="/etc/ssh/backup_scripts/temp_ssh_access.json"

# Backup the original JSON file (currently commented out) 🗂️
# cp "$JSON_FILE" "$JSON_FILE.bak"

# Create an empty temporary file ✨
: > "$TEMP_JSON_FILE"

# Function to check if a PID is active 🔍
is_pid_active() {
    local pid=$1
    if ps -p $pid > /dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}

# Read and process each object in the JSON file 📜
jq -c '.[]' "$JSON_FILE" | while IFS= read -r entry; do
    pid=$(echo "$entry" | jq -r '.pid')
    active_status=$(echo "$entry" | jq -r '.active')

    # Only check PID status if current status is active ✅
    if [[ "$active_status" == "true" ]]; then
        new_active_status=$(is_pid_active "$pid")
        # Update the JSON object with the new active status 🔄
        updated_entry=$(echo "$entry" | jq --argjson active "$new_active_status" '.active = $active')
    else
        updated_entry="$entry"
    fi

    # Append the updated entry to the temporary file 📝
    echo "$updated_entry" >> "$TEMP_JSON_FILE"
done

# Create a new JSON array in the temporary file 🔢
jq -s '.' "$TEMP_JSON_FILE" > "$JSON_FILE"

# Clean up temporary files 🧹
rm "$TEMP_JSON_FILE"

echo "✅ JSON file updated successfully."