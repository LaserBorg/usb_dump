#!/bin/bash

# Check if INSTALL_DIR is provided as a parameter
if [ -z "$1" ]; then
    # Prompt the user to enter the INSTALL_DIR
    read -p "Enter the parent directory for installation (default: /home/pi): " INSTALL_DIR
    # Use default value if no input is provided
    INSTALL_DIR=${INSTALL_DIR:-/home/pi}
else
    INSTALL_DIR=$1
fi

# Verify that the directory exists or create it
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
fi

# Install udevil
echo "Installing udevil..."
sudo apt-get update && sudo apt-get install -y udevil

# Clone the repository
git clone https://github.com/LaserBorg/usb_dump "$INSTALL_DIR/usb_dump"

# Define the full path to the cloned repository
REPO_DIR="$INSTALL_DIR/usb_dump"

# Copy udev rule and systemd service to their target folders
sudo cp "$REPO_DIR/99-usbdump.rules" /etc/udev/rules.d/
sudo cp "$REPO_DIR/usbdump@.service" /etc/systemd/system/

# Make the wrapper and Python scripts executable
chmod +x "$REPO_DIR/usbdump.sh"
chmod +x "$REPO_DIR/usbdump.py"

# Set the environment variable
echo "export USBDUMP_DIR=$REPO_DIR" >> ~/.bashrc
source ~/.bashrc

# Reload udev rules and the systemd daemon
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl daemon-reload

echo "Installation complete. Please reboot your system."