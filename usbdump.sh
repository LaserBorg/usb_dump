#!/bin/bash
LOG_FILE="/tmp/usbdump.log"
PYTHON_SCRIPT="$USBDUMP_DIR/usbdump.py"

echo "$(date): Script started for device $1" >> "$LOG_FILE"
echo "$(date): USBDUMP_DIR is set to: $USBDUMP_DIR" >> "$LOG_FILE"
echo "$(date): Current working directory: $(pwd)" >> "$LOG_FILE"

# Use lsblk to get device information
DEVICE_INFO=$(lsblk -nlo NAME,UUID,FSTYPE,MOUNTPOINT /dev/$1)
echo "$(date): Device info from lsblk: $DEVICE_INFO" >> "$LOG_FILE"

# Extract UUID and other relevant information
UUID=$(echo "$DEVICE_INFO" | awk '{print $2}')
FS_TYPE=$(echo "$DEVICE_INFO" | awk '{print $3}')
MOUNT_POINT=$(echo "$DEVICE_INFO" | awk '{print $4}')

echo "$(date): Extracted info - UUID: $UUID, Filesystem: $FS_TYPE, Mount point: $MOUNT_POINT" >> "$LOG_FILE"

if [ -z "$UUID" ]; then
    echo "$(date): Error - UUID not found for device $1" >> "$LOG_FILE"
    exit 1
fi

if [ -z "$MOUNT_POINT" ]; then
    echo "$(date): Mount point not found. Attempting to mount the device." >> "$LOG_FILE"
    MOUNT_POINT="/media/pi/$UUID"
    
    # Clean up any existing mount point with the same name
    if [ -d "$MOUNT_POINT" ]; then
        echo "$(date): Cleaning up existing mount point $MOUNT_POINT" >> "$LOG_FILE"
        sudo rmdir "$MOUNT_POINT" 2>> "$LOG_FILE"
        if [ $? -ne 0 ]; then
            echo "$(date): Warning - Could not remove existing mount point. It might not be empty." >> "$LOG_FILE"
        fi
    fi
    
    sudo mkdir -p "$MOUNT_POINT"
    sudo mount /dev/$1 "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "$(date): Error - Failed to mount the device" >> "$LOG_FILE"
        exit 1
    fi
    echo "$(date): Device mounted at $MOUNT_POINT" >> "$LOG_FILE"
else
    echo "$(date): Device already mounted at $MOUNT_POINT" >> "$LOG_FILE"
fi

# Check if Python script exists
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "$(date): Error - Python script not found at $PYTHON_SCRIPT" >> "$LOG_FILE"
    exit 1
fi

# Execute the Python script
echo "$(date): Executing Python script" >> "$LOG_FILE"
/usr/bin/python3 "$PYTHON_SCRIPT" "$MOUNT_POINT" >> "$LOG_FILE" 2>&1
PYTHON_EXIT_CODE=$?

echo "$(date): Python script execution completed with exit code $PYTHON_EXIT_CODE" >> "$LOG_FILE"

# Unmount the device if we mounted it
if [ "$MOUNT_POINT" = "/media/pi/$UUID" ]; then
    echo "$(date): Unmounting the device" >> "$LOG_FILE"
    sudo umount "$MOUNT_POINT"
    sudo rmdir "$MOUNT_POINT"
fi

echo "$(date): Script completed. Device can be safely removed." >> "$LOG_FILE"

exit $PYTHON_EXIT_CODE