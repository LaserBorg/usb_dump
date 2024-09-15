## Dumping Data to USB Storage

The script installs **udevil** to mount USB devices since console-based OS (RPiOS lite) do not mount them automatically.  

1. Enter the target directory, clone the repository and run the installer:
   ```
   cd /home/pi
   git clone https://github.com/LaserBorg/usb_dump
   cd usb_dump
   chmod +x install.sh && ./install.sh "$(pwd)"
   ```

2. Create the config file:
    ```
    echo '{"source_directories": ["/home/pi/Documents"], "target_root_directory": "Documents"}' > usbdump.json
    ```

Note: The log file is located at `/tmp/usbdump.log`. If you want to change this, you'll need to update the `LOG_FILE` variable in the `usbdump.sh` script.

Troubleshooting:
- Check the log file:
   ```
   tail -f /tmp/usbdump.log
   ```
- If the system isn't detecting USB drives, check the udev rule and systemd service for any errors.
- Ensure all paths in the scripts and service files are correct, especially if you've moved files to different locations.
- Check system logs for any errors: `sudo journalctl -f`
- to manually mount/unmount a drive using udevil:
   ```
   udevil mount /dev/sda1
   udevil umount /dev/sda1
   ```