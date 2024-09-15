#!/usr/bin/env python3

import sys
import os
import json
import shutil

def load_config(config_path):
    with open(config_path, 'r') as f:
        return json.load(f)

def backup_directories(config, mount_point):
    target_root = os.path.join(mount_point, config['target_root_directory'])
    os.makedirs(target_root, exist_ok=True)

    if not os.access(target_root, os.W_OK):
        print(f"Error: No write permission for directory {target_root}")
        return

    for source_dir in config['source_directories']:
        if os.path.exists(source_dir):
            target_dir = os.path.join(target_root, os.path.basename(source_dir))
            try:
                shutil.copytree(source_dir, target_dir, dirs_exist_ok=True)
                print(f"Successfully backed up {source_dir} to {target_dir}")
            except Exception as e:
                print(f"Error backing up {source_dir} to {target_dir}: {e}")
        else:
            print(f"Source directory {source_dir} does not exist")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 usb_dump.py <mount_point>")
        sys.exit(1)

    mount_point = sys.argv[1]
    config_path = os.path.join(os.path.dirname(__file__), 'usb_dump.json')

    if not os.path.exists(config_path):
        print(f"Configuration file {config_path} not found")
        sys.exit(1)

    config = load_config(config_path)
    backup_directories(config, mount_point)
