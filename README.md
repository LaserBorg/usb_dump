## Dumping Data to USB Storage

The script installs **udevil** to mount USB devices since console-based OS (RPiOS lite) do not mount them automatically.  

Enter your target directory and run the installer script:
   ```
   cd /home/pi

   wget https://raw.githubusercontent.com/LaserBorg/usb_dump/main/install.sh
   chmod +x install.sh
   ./install.sh "$(pwd)"
   ```

Note: The log file is located at `/tmp/usb_detector.log`. If you want to change this, you'll need to update the `LOG_FILE` variable in the `usb_dump.sh` script.

Troubleshooting:
- Check the log file:
   ```
   tail -f /tmp/usb_detector.log
   ```
- If the system isn't detecting USB drives, check the udev rule and systemd service for any errors.
- Ensure all paths in the scripts and service files are correct, especially if you've moved files to different locations.
- Check system logs for any errors: `sudo journalctl -f`
- to manually mount/unmount a drive using udevil:
   ```
   udevil mount /dev/sda1
   udevil umount /dev/sda1
   ```