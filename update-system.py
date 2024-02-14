#!/usr/bin/env python

import os
import shutil
import subprocess
import sys

# Define privilege escalation type
privilege = "sudo" if shutil.which("sudo") else ""

# Check distribution, fallback check via os-release also defined
lsb_release = "/etc/lsb-release"
os_release = "/etc/os-release"

# Set flatpak path
flatpak = shutil.which("flatpak")

# Set variable based on availability
if os.path.isfile(lsb_release):
    with open(lsb_release, "r") as lsb_release:
        check_distro = lsb_release.read()
elif os.path.isfile(os_release):
    with open(os_release, "r") as os_release:
        check_distro = os_release.read()
else:
    print("ERROR: Both files do not exist, could not determine distribution.")
    sys.exit(1)

# Log update output to a file in the cache directory
os.makedirs(os.path.expanduser("~/.cache/update-system"), exist_ok=True)
# Output everything into a file for later troubleshooting if needed
update_log = os.path.expanduser("~/.cache/update-system/update.log")

print("\nThis script will update your system.\n")

# Get privilege to update the system
os.system(f"{privilege} echo 'Checking for possible updates, it takes a short moment...' >> {update_log}")
os.system(f"date >> {update_log}")

# Check for distribution and execute commands to update
if any(keyword.lower() in check_distro.lower() for keyword in ['ubuntu', 'debian']):
    os.system(f"{privilege} apt update >> {update_log}")
    os.system(f"{privilege} apt upgrade -y >> {update_log}")
    os.system(f"{privilege} apt purge --auto-remove -y >> {update_log}")
    os.system(f"{privilege} snap refresh 2>> {update_log}")
else:
    # For whatever reason no distribution is found, commands will be executed either way.
    os.system(f"{privilege} apt update -y >> {update_log}")
    os.system(f"{privilege} apt upgrade -y >> {update_log}")
    os.system(f"{privilege} apt purge --auto-remove >> {update_log}")

print("\n### Flatpaks are now being checked ### \n")

os.system(f"{flatpak} update 2>> {update_log}")

# Prompting for confirmation
print("\nThese following flatpaks are no longer needed and can be uninstalled:\n")

# Remove unused/leftover flatpaks
os.system(f"{flatpak} uninstall --unused 2>> {update_log} || echo 'Flatpak is not installed on the system'")
