#!/bin/bash

set -e

echo "Starting snapd removal process..."

# Stop snapd services
echo "Stopping snapd services..."
sudo systemctl stop snapd.socket snapd.service 2>/dev/null || true
sudo systemctl disable snapd.socket snapd.service 2>/dev/null || true

# Remove snap directories
echo "Removing snap directories..."
rm -rf /var/lib/snapd
rm -rf /usr/lib/snapd

echo "Snapd removal completed successfully."
