#!/bin/bash

# Check if USBDUMP_DIR is provided as a parameter
if [ -z "$1" ]; then
    # Prompt the user to enter the USBDUMP_DIR
    read -p "Enter the parent directory for installation (default: $(pwd)): " USBDUMP_DIR
    # Use the current directory as the default value if no input is provided
    USBDUMP_DIR=${USBDUMP_DIR:-$(pwd)}
else
    USBDUMP_DIR=$1
fi

# Verify that the directory exists or create it
if [ ! -d "$USBDUMP_DIR" ]; then
    mkdir -p "$USBDUMP_DIR"
fi

# Install udevil
echo "Installing udevil..."
sudo apt-get update && sudo apt-get install -y udevil

# Copy udev rule and systemd service to their target folders
sudo cp "$USBDUMP_DIR/99-usbdump.rules" /etc/udev/rules.d/
sudo cp "$USBDUMP_DIR/usbdump@.service" /etc/systemd/system/

# Make the wrapper and Python scripts executable
chmod +x "$USBDUMP_DIR/usbdump.sh"
chmod +x "$USBDUMP_DIR/usbdump.py"

# Set the environment variable
echo "export USBDUMP_DIR=$USBDUMP_DIR" >> ~/.bashrc
source ~/.bashrc

# Reload udev rules and the systemd daemon
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl daemon-reload

echo "Installation complete. Please reboot your system."