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

# Set the environment variable system-wide
echo "USBDUMP_DIR=$USBDUMP_DIR" | sudo tee -a /etc/environment

# Also set it for the current session
export USBDUMP_DIR=$USBDUMP_DIR

# Update the systemd service file to use the environment variable
sudo sed -i 's|ExecStart=.*|ExecStart=/bin/sh -c '\''/usr/bin/udevil mount /dev/%I > /tmp/usbdump.log 2>\&1 \&\& $USBDUMP_DIR/usbdump.sh /dev/%I'\''|' /etc/systemd/system/usbdump@.service

# Reload udev rules and the systemd daemon
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl daemon-reload

echo "Installation complete. USBDUMP_DIR set to $USBDUMP_DIR. Please reboot your system for changes to take effect."