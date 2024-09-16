#!/bin/bash

# Function to check script name
check_script_name() {
  PARENT_DIR="$(basename "$(pwd)")"
  EXPECTED_DIR="ssh-excel-monitor"
  if [[ "$PARENT_DIR" != "$EXPECTED_DIR" ]]; then
      echo "⚠️ You have to be inside 'ssh-excel-monitor' folder."
      echo "Current folder is: $PARENT_DIR"
      exit 1
  fi
}

# Function to check if the script has execute permission
check_permissions() {
    if [ ! -x "$0" ]; then
        echo "⚠️ The script does not have execute permissions. Please run: chmod +x $0 to make it executable."
        exit 1
    fi
}

# Function to prompt user for agreement
prompt_agreement() {
    echo "👋 Welcome to the install script!"
    echo "This script will perform the following actions:"
    echo "1. Back up the files to /etc/ssh/backup_scripts."
    echo "2. Add a cron job to run /etc/ssh/backup_scripts/ssh_client_tracker.sh every minute."
    echo "3. Update the SSH configuration to set the ForceCommand directive."
    echo "4. Restart the SSH service to apply the changes."
    echo "5. Copy serve_api.py and ssh-monitor.service to the appropriate directories."
    echo "6. Reload the systemd daemon and start the ssh-monitor service."
    echo ""
    echo "Do you agree to proceed? (Y/y/Yes/yes/YES to agree, any other key to disagree): "

    read -r USER_INPUT
    case "$USER_INPUT" in
        [Yy]|[Yy][Ee][Ss]|[Yy][Ee][Ss][Yy]|[Yy][Ee][Ss][Yy][Ee][Ss]|[Yy][Ee][Ss][Yy][Ee][Ss][Yy])
            echo "👍 Thank you for agreeing. We'll now proceed with the script."
            ;;
        *)
            echo "🚫 It seems you prefer not to proceed. The script will now exit."
            exit 1
            ;;
    esac
}

# Function to safely copy files with error handling
safe_copy() {
    local src_file="$1"
    local dest_file="$2"

    if cp "$src_file" "$dest_file"; then
        echo "✅ Successfully copied $src_file to $dest_file."
    else
        echo "⚠️ An error occurred while copying $src_file to $dest_file."
        exit 1
    fi
}

# Function to back up required files
backup_files() {
    # Source files 🗂️
    SCRIPT_DIR=$(dirname "$0")
    SSH_CLIENT_TRACKER="$SCRIPT_DIR/ssh_client_tracker.sh"
    SSH_MANAGER="$SCRIPT_DIR/ssh_manager.sh"

    # Destination files 🏁
    BACKUP_CLIENT_TRACKER="$BACKUP_DIR/ssh_client_tracker.sh"
    BACKUP_MANAGER="$BACKUP_DIR/ssh_manager.sh"

    echo "📁 Preparing to back up files to $BACKUP_DIR..."

    # Copy files to the backup directory
    safe_copy "$SSH_CLIENT_TRACKER" "$BACKUP_CLIENT_TRACKER"
    safe_copy "$SSH_MANAGER" "$BACKUP_MANAGER"

    echo "🎉 Backup completed successfully!"

    # Set execute permissions for the backup files 🛠️
    echo "🔧 Setting execute permissions for the backup files."
    chmod +x "$BACKUP_CLIENT_TRACKER" "$BACKUP_MANAGER"

    echo "✅ Permissions set successfully for the backup files."
}

# Function to add cron job
add_cron_job() {
    # Define the cron job 🕒
    CRON_JOB="* * * * * /etc/ssh/backup_scripts/ssh_client_tracker.sh"

    # Try to add cron job, with error handling 🌟
    if crontab -l | grep -qF "$CRON_JOB"; then
        echo "⚠️ The cron job is already present in crontab."
    else
        echo "➕ Adding the cron job to crontab."
        # Add the cron job and check for success ✅
        (crontab -l; echo "$CRON_JOB") | crontab -
        if [ $? -eq 0 ]; then
            echo "✅ Cron job added successfully."
        else
            echo "⚠️ An error occurred while adding the cron job."
        fi
    fi
}

# Function to update ForceCommand in SSH config
update_force_command() {
    # Path to SSH configuration file 🛠️
    SSH_CONFIG="/etc/ssh/sshd_config"
    # Desired ForceCommand value 🎯
    NEW_FORCECOMMAND="ForceCommand /etc/ssh/backup_scripts/ssh_manager.sh"

    # Check if ForceCommand is set 🔍
    if grep -q "^ForceCommand" "$SSH_CONFIG"; then
        echo "⚙️ The ForceCommand is already set. Updating the value."
        # Try to update the ForceCommand line 📝
        sudo sed -i "s|^ForceCommand.*|$NEW_FORCECOMMAND|" "$SSH_CONFIG"
        if [ $? -eq 0 ]; then
            echo "✅ ForceCommand updated successfully."
        else
            echo "⚠️ An error occurred while updating the ForceCommand."
            return 1
        fi
    elif grep -q "^#ForceCommand" "$SSH_CONFIG"; then
        echo "🔧 The ForceCommand is commented out. Uncommenting and updating the value."
        # Try to uncomment and update ForceCommand ✂️📝
        sudo sed -i "s|^#ForceCommand.*|$NEW_FORCECOMMAND|" "$SSH_CONFIG"
        if [ $? -eq 0 ]; then
            echo "✅ ForceCommand uncommented and updated successfully."
        else
            echo "⚠️ An error occurred while uncommenting and updating the ForceCommand."
            return 1
        fi
    else
        echo "➕ The ForceCommand is not set. Adding it to the config."
        # Try to append ForceCommand 🖋️
        echo "$NEW_FORCECOMMAND" | sudo tee -a "$SSH_CONFIG" > /dev/null
        if [ $? -eq 0 ]; then
            echo "✅ ForceCommand added successfully."
        else
            echo "⚠️ An error occurred while adding the ForceCommand."
            return 1
        fi
    fi

    # Restart SSH service 🔄
    echo "🚀 Restarting SSH service to apply changes."
    sudo systemctl restart sshd
    if [ $? -eq 0 ]; then
        echo "✅ SSH service restarted successfully."
    else
        echo "⚠️ An error occurred while restarting the SSH service."
        return 1
    fi
}

# Function to copy serve_api.py to /etc/ssh/backup_scripts/
copy_serve_api() {
    local src_file="serve_api.py"
    local dest_file="/etc/ssh/backup_scripts/serve_api.py"

    echo "📁 Copying $src_file to $dest_file..."
    safe_copy "$src_file" "$dest_file"
}

# Function to copy ssh-monitor.service to /etc/systemd/system/
copy_service_file() {
    local src_file="ssh-monitor.service"
    local dest_file="/etc/systemd/system/ssh-monitor.service"

    echo "📁 Copying $src_file to $dest_file..."
    safe_copy "$src_file" "$dest_file"
}

# Function to reload systemd daemon and start the service
reload_and_start_service() {
    echo "🔄 Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "🚀 Starting ssh-monitor service..."
    sudo systemctl start ssh-monitor.service

    # Check service status
    if systemctl is-active --quiet ssh-monitor.service; then
        echo "✅ ssh-monitor service started successfully."
    else
        echo "⚠️ An error occurred while starting the ssh-monitor service."
        exit 1
    fi
}

# Function to delete the backup folder
delete_backup_folder() {
    echo "⚠️ This action will delete the backup folder: $pwd."
    echo "Do you agree to proceed with the deletion? (Enter/Yes/YES/yes/Y/y to agree, any other key to disagree): "

    read -r USER_INPUT
    case "$USER_INPUT" in
        [Yy]|[Yy][Ee][Ss]|[Yy][Ee][Ss][Yy]|[Yy][Ee][Ss][Yy][Ee][Ss]|[Yy][Ee][Ss][Yy][Ee][Ss][Yy])
            echo "🔄 Deleting the backup folder."
            sudo rm -rf "$pwd"
            if [ $? -eq 0 ]; then
                echo "✅ Backup folder deleted successfully."
            else
                echo "⚠️ An error occurred while deleting the backup folder."
            fi
            ;;
        *)
            echo "🚫 Deletion canceled. The script will now exit."
            exit 1
            ;;
    esac
}

# Main script execution
check_script_name
prompt_agreement
check_permissions

# Define the backup directory 📁
BACKUP_DIR="/etc/ssh/backup_scripts"

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

# Execute the functions with basic error handling
echo "📁 Starting file backup..."
backup_files

echo "🕒 Adding the cron job."
add_cron_job

echo "🔧 Updating the ForceCommand."
update_force_command

echo "📁 Copying serve_api.py and ssh-monitor.service."
copy_serve_api
copy_service_file

echo "🔄 Reloading systemd daemon and starting the service."
reload_and_start_service

# Optionally delete the backup folder
echo "🗑️ Optionally, delete the backup folder after usage."
delete_backup_folder

echo "🏁 All tasks have been completed successfully!"
