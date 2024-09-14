<div align="center">

<img src="https://github.com/Sulaymon-Dev20/ssh-excel-monitor/blob/main/ssh-logo.png?raw=true" width="200" alt='ssh logo'/>
<img src="https://github.com/Sulaymon-Dev20/ssh-excel-monitor/blob/main/sheet-logo.png?raw=true" width="200" alt='google sheets logo'/>

# SSH EXCEL MONITOR
The SSH Excel Monitor project tracks and logs SSH access details in real-time, automatically recording data such as access time, IP address, and process ID, and exports this information into an organized Excel sheet for easy monitoring and analysis.
</div>


## Components

### `install.sh`

- **Purpose**: Sets up and configures the environment, including SSH settings and cron jobs.
- **Features**:
    - Prompts for user confirmation before making changes.
    - Updates the `ForceCommand` setting in the SSH configuration.
    - Adds a cron job for periodic updates.
    - Manages script permissions and backups.
    - Handles folder deletion with user confirmation.

### `ssh_client_tracker.sh`

- **Purpose**: Logs SSH client connections to a JSON file.
- **Features**:
    - Initializes the log file if it doesn’t exist.
    - Appends connection details such as timestamps, IP addresses, and command details.
    - Executes the original SSH command or defaults to the shell if no command is provided.

### `ssh_manager.sh`

- **Purpose**: Manages and updates SSH configurations.
- **Features**:
    - Updates the `ForceCommand` setting in the SSH configuration file.
    - Ensures proper file permissions and backups.
    - Restarts the SSH service to apply changes.

### `apps_script.js`

- **Purpose**: Provides Google Apps Script code to integrate and manage SSH access data in Google Sheets.
- **Features**:
    - Allows data from the SSH logs to be imported into Google Sheets.
    - Facilitates Excel-like data manipulation and visualization.

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/Sulaymon-Dev20/ssh-excel-monitor
    ```

2. Navigate to the project directory:
    ```bash
    cd ssh-excel-monitor
    ```

3. Run the `install.sh` script:
    ```bash
    sudo bash install.sh
    ```

4. Deploy the `apps_script.js` to Google Sheets:
    - Open Google Sheets and navigate to Extensions > Apps Script.
    - Paste the content of `apps_script.js` into the script editor and save.

## Usage

<div align="center">

[![HOW TO USE RELNOTE](https://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](https://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE)
</div>

- **`install.sh`**: Use this script to configure the environment and set up necessary components.
- **`ssh_client_tracker.sh`**: Automatically executed by the SSH service to log client connections.
- **`ssh_manager.sh`**: Use this script for managing and updating SSH configurations.
- **`apps_script.js`**: Utilize this script within Google Sheets for monitoring and analyzing SSH access data.

## Contributing

1. Fork the repository.
2. Create a new branch for your feature or fix.
3. Commit your changes with clear messages.
4. Push your branch to your forked repository.
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

For questions or feedback, please contact:
- **Name**: Nuriddin Bobonorov
- **Email**: [sulaymon1w@gmail.com](mailto:sulaymon1w@gmail.com)
