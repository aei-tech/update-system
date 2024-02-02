#!/bin/env bash

# Define privilege escalation type
PRIVILEGE="$(which sudo)"

# Check distribution, fallback check via os-release also defined
LSB_RELEASE="/etc/lsb-release"
OS_RELEASE="/etc/os-release"

# Set flatpak path
FLATPAK="$(which flatpak)"

# Set variable based on availability
if test -f $LSB_RELEASE; then
    CHECK_DISTRO="$(cat $LSB_RELEASE)"
elif test -f $OS_RELEASE; then
    CHECK_DISTRO="$(cat $OS_RELEASE)"
else
    echo "ERROR: Both files do not exist, aborting..."
    exit 1
fi

# Log update output to a file in the cache directory
cd "$HOME" && mkdir -p "$HOME/.cache/update_packages/"
# Output everything into a file for later troubleshooting if needed
OUTPUT="$HOME/.cache/update_packages/updates_info.log"

echo -en "\nThis script updates your system\n"

# Get privilege to update the system
"$PRIVILEGE" echo "Checking for possible updates, it takes a short moment..."
date >> "$OUTPUT"

# Check for distribution and execute commands to update
if echo "$CHECK_DISTRO" | grep -q -i -e 'Ubuntu' -e 'Debian'; then
    "$PRIVILEGE" apt update 1> "$OUTPUT"
    "$PRIVILEGE" apt upgrade && "$PRIVILEGE" apt purge --auto-remove && echo "All updates have been successfully completed"
    "$PRIVILEGE" snap refresh 2>> "$OUTPUT"
else
# For whatever reason no distribution is found, commands wil be executed either way.
    "$PRIVILEGE" apt update -y && echo "Package database successfully updated. Now follows the update of the packages..."
    "$PRIVILEGE" apt upgrade && echo "All updates have been successfully completed." && "$PRIVILEGE" apt purge --auto-remove
fi

echo -en "\n### Flatpaks are now being checked ### \n"

"$FLATPAK" update 2>> "$OUTPUT"

# Prompting for conformation
echo -en "\nThese following flatpaks are no longer needed and can be uninstalled:\n"

# Remove unused/leftover flatpaks
"$FLATPAK" uninstall --unused 2>> "$OUTPUT" || echo "Flatpak is not installed on the system"
