#!/usr/bin/env python3

import sys
import os
import json
import shutil


def load_config(config_path):
    with open(config_path, 'r') as f:
        return json.load(f)

def files_are_identical(src, dst):
    return (os.path.getsize(src) == os.path.getsize(dst) and
            os.path.getmtime(src) == os.path.getmtime(dst))

def copy_directories(config, mount_point):
    target_root_directory = config.get('target_root_directory')
    if target_root_directory is not None:
        target_root = os.path.join(mount_point, target_root_directory)
    else:
        target_root = mount_point

    os.makedirs(target_root, exist_ok=True)

    if not os.access(target_root, os.W_OK):
        print(f"Error: No write permission for directory {target_root}")
        return

    for source_dir in config['source_directories']:
        if os.path.exists(source_dir):
            target_dir = os.path.join(target_root, os.path.basename(source_dir))
            try:
                for root, _, files in os.walk(source_dir):
                    relative_path = os.path.relpath(root, source_dir)
                    target_sub_dir = os.path.join(target_dir, relative_path)
                    os.makedirs(target_sub_dir, exist_ok=True)
                    for file in files:
                        src_file = os.path.join(root, file)
                        dst_file = os.path.join(target_sub_dir, file)
                        if os.path.exists(dst_file) and files_are_identical(src_file, dst_file):
                            # print(f"Skipping identical file {src_file}")
                            pass
                        else:
                            shutil.copy2(src_file, dst_file)
                            print(f"Copied {src_file} to {dst_file}")
            except Exception as e:
                print(f"Error backing up {source_dir} to {target_dir}: {e}")
        else:
            print(f"Source directory {source_dir} does not exist")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 usbdump.py <mount_point>")
        sys.exit(1)

    mount_point = sys.argv[1]
    config_path = os.path.join(os.path.dirname(__file__), 'usbdump.json')

    if not os.path.exists(config_path):
        print(f"Configuration file {config_path} not found")
        sys.exit(1)

    config = load_config(config_path)
    copy_directories(config, mount_point)
