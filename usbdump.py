#!/usr/bin/env python3

import sys
import os
import json
import shutil
import logging

# Configure logging
LOG_FILE = "/tmp/usbdump.log"
logging.basicConfig(filename=LOG_FILE, level=logging.DEBUG, format='%(asctime)s %(message)s')

def load_config(config_path):
    logging.debug(f"Loading config from {config_path}")
    with open(config_path, 'r') as f:
        return json.load(f)

def files_are_identical(src, dst):
    identical = (os.path.getsize(src) == os.path.getsize(dst) and
                 os.path.getmtime(src) == os.path.getmtime(dst))
    logging.debug(f"Files {src} and {dst} are {'identical' if identical else 'different'}")
    return identical

def copy_directories(config, mount_point):
    target_root_directory = config.get('target_root_directory')
    if target_root_directory is not None:
        target_root = os.path.join(mount_point, target_root_directory)
    else:
        target_root = mount_point

    os.makedirs(target_root, exist_ok=True)
    logging.debug(f"Target root directory: {target_root}")

    if not os.access(target_root, os.W_OK):
        logging.error(f"No write permission for directory {target_root}")
        print(f"Error: No write permission for directory {target_root}")
        return

    for source_dir in config['source_directories']:
        if os.path.exists(source_dir):
            target_dir = os.path.join(target_root, os.path.basename(source_dir))
            logging.debug(f"Copying from {source_dir} to {target_dir}")
            try:
                for root, _, files in os.walk(source_dir):
                    relative_path = os.path.relpath(root, source_dir)
                    target_sub_dir = os.path.join(target_dir, relative_path)
                    os.makedirs(target_sub_dir, exist_ok=True)
                    for file in files:
                        src_file = os.path.join(root, file)
                        dst_file = os.path.join(target_sub_dir, file)
                        if os.path.exists(dst_file) and files_are_identical(src_file, dst_file):
                            logging.debug(f"Skipping identical file {src_file}")
                        else:
                            shutil.copy2(src_file, dst_file)
                            logging.debug(f"Copied {src_file} to {dst_file}")
            except Exception as e:
                logging.error(f"Error backing up {source_dir} to {target_dir}: {e}")
                print(f"Error backing up {source_dir} to {target_dir}: {e}")
        else:
            logging.warning(f"Source directory {source_dir} does not exist")
            print(f"Source directory {source_dir} does not exist")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        logging.error("Usage: python3 usbdump.py <mount_point>")
        print("Usage: python3 usbdump.py <mount_point>")
        sys.exit(1)

    mount_point = sys.argv[1]
    config_path = os.path.join(os.path.dirname(__file__), 'usbdump.json')

    if not os.path.exists(config_path):
        logging.error(f"Configuration file {config_path} not found")
        print(f"Configuration file {config_path} not found")
        sys.exit(1)

    config = load_config(config_path)
    copy_directories(config, mount_point)