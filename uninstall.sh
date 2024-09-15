#!/bin/bash

# Check if USBDUMP_DIR is set
if [ -z "$USBDUMP_DIR" ]; then
    echo "USBDUMP_DIR is not set. Please set it before running this script."
    exit 1
fi

# Remove udev rule and systemd service
echo "Removing udev rule and systemd service..."
sudo rm /etc/udev/rules.d/99-usbdump.rules
sudo rm /etc/systemd/system/usbdump@.service

# Reload udev rules and the systemd daemon
sudo udevadm control --reload-rules && sudo udevadm trigger
sudo systemctl daemon-reload

# Remove the USBDUMP_DIR directory
echo "Removing USBDUMP_DIR..."
rm -rf "$USBDUMP_DIR"

echo "Uninstallation complete."