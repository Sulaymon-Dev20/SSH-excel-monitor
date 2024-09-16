import http.server
import socketserver
import os
import uuid
import json
import argparse

# File to store the API key
API_KEY_FILE = '/etc/ssh/backup_scripts/api_key.txt'
# File to serve if the API key is correct
SSH_ACCESS_JSON = '/etc/ssh/backup_scripts/ssh_access.json'
PORT = 8000

# Function to generate or retrieve the API key
def get_or_create_api_key():
    if os.path.exists(API_KEY_FILE):
        # Read the API key from the file if it exists
        with open(API_KEY_FILE, 'r') as f:
            api_key = f.read().strip()
    else:
        # Generate a new API key and save it to the file
        api_key = str(uuid.uuid4())
        with open(API_KEY_FILE, 'w') as f:
            f.write(api_key)
    return api_key

# Function to prompt the user to change the API key
def prompt_for_api_key_change(change_key):
    if change_key:
        # Generate a new API key and save it to the file
        api_key = str(uuid.uuid4())
        with open(API_KEY_FILE, 'w') as f:
            f.write(api_key)
        print(f"API key has been changed to: {api_key}")
    else:
        api_key = get_or_create_api_key()
        print(f"Using existing API key: {api_key}")
    return api_key

# Set up command-line argument parsing
parser = argparse.ArgumentParser(description='Start the server with API key options.')
parser.add_argument('--change-key', action='store_true', help='Generate a new API key')
args = parser.parse_args()

# Determine API key based on command-line argument
API_KEY = prompt_for_api_key_change(args.change_key)

class APIKeyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Parse the requested path
        if self.path.startswith('/apikey/'):
            # Extract the API key from the URL path
            requested_key = self.path.split('/')[-1]

            if requested_key == API_KEY:
                # If the API key is correct, return the ssh_access.json file
                if os.path.exists(SSH_ACCESS_JSON):
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    with open(SSH_ACCESS_JSON, 'r') as json_file:
                        data = json_file.read()
                    self.wfile.write(data.encode())
                else:
                    # If ssh_access.json file does not exist, return an error
                    self.send_response(404)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    response = {"error": "ssh_access.json file not found."}
                    self.wfile.write(json.dumps(response).encode())
            else:
                # Return a 403 error if the API key is incorrect
                self.send_response(403)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                response = {"error": "Invalid API key."}
                self.wfile.write(json.dumps(response).encode())
        else:
            # Return a 404 error for other paths
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'404 Not Found')

# Set up the server
with socketserver.TCPServer(("", PORT), APIKeyHandler) as httpd:
    print(f"Serving on port {PORT} with API key: {API_KEY}")
    httpd.serve_forever()