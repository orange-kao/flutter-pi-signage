#!/usr/bin/env python3

from flask import Flask
import threading
import os
import subprocess
import glob
import re

RCLONE_NOTHING_TO_TRANSFER_MESSAGE = "There was nothing to transfer"

app = Flask(__name__)
lock = threading.Lock()  # only work if there is only one process

@app.route("/<signage_id>")
def refresh_signage_preview(signage_id):
    if not re.match(r"\A[0-9][0-9]\Z", signage_id):
        return ""
    print(f"Singage ID {signage_id}")
    with lock:
        print("Lock entered")
        run_rclone()
        return build_list(signage_id)

def run_rclone():
    # os.chdir(os.environ.get("HOME"))
    os.chdir("/var/www/digital-signage")
    rclone_ret = subprocess.run(["rclone", "sync", "-v", "signage-all-slides:./", "./signage-all-slides/"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if rclone_ret.returncode != 0:
        # something is wrong
        print(rclone_ret.stdout)
        print(rclone_ret.stderr)
        print("Failed to sync from WebDAV server")
        raise RuntimeError("Error reading from nextCloud")

    if (RCLONE_NOTHING_TO_TRANSFER_MESSAGE in rclone_ret.stdout or RCLONE_NOTHING_TO_TRANSFER_MESSAGE in rclone_ret.stderr):
        print("Nothing to transfer")
    else:
        print(rclone_ret.stdout)
        print(rclone_ret.stderr)

def build_list(signage_id):
    signage_dir = f"./signage-all-slides/signage-{signage_id}"
    if not os.path.isdir(signage_dir):
        print("Direcotry does not exist")
        return ""
    file_list = []
    for filename in os.listdir(signage_dir):
        if os.path.isfile(os.path.join(signage_dir, filename)):
            file_list.append(filename)
    file_list.sort()
    file_list_str = "\n".join(file_list)
    print("File list returned: " + repr(file_list_str))
    return file_list_str

