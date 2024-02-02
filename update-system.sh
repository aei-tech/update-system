#!/bin/env bash

# Define privilege escalation type
privilege="$(which sudo)"

# Check distribution, fallback check via os-release also defined
lsb_release="/etc/lsb-release"
os_release="/etc/os-release"

# Set flatpak path
flatpak="$(which flatpak)"

# Set variable based on availability
if test -f $lsb_release; then
    check_distro="$(cat $lsb_release)" # Get distribution info from lsb-release file
elif test -f $os_release; then
    check_distro="$(cat $os_release)" # Fallback to os-release file if lsb-release file does not exist
else
    echo "ERROR: Both files do not exist, aborting..." # Print error message if both files do not exist
    exit 1
fi

# Log update output to a file in the cache directory
cd "$HOME" && mkdir -p "$HOME/.cache/update_packages/" # Change directory to home and create cache directory if it does not exist
# Output everything into a file for later troubleshooting if needed
output="$HOME/.cache/update_packages/updates_info.log"
echo "Log file created at $output" # Log the creation of the updates_info.log file

echo -en "\nThis script updates your system\n" # Print message indicating that the script updates the system

# Get privilege to update the system
"$privilege" echo "Checking for possible updates, it takes a short moment..." >> "$output" # Use sudo to echo a message for checking possible updates and redirect the output to the updates_info.log file
date >> "$output" # Append current date and time to the updates_info.log file

# Check for distribution and execute commands to update
if echo "$check_distro" | grep -q -i -e 'Ubuntu' -e 'Debian'; then
    "$privilege" apt update 1>> "$output" # Use sudo to update apt package index and redirect the output to the updates_info.log file
    "$privilege" apt upgrade && "$privilege" apt purge --auto-remove && echo "All updates have been successfully completed" >> "$output" # Use sudo to upgrade and remove unnecessary packages for Ubuntu and Debian
    "$privilege" snap refresh 2>> "$output" # Use sudo to refresh snap packages and append the output to the updates_info.log file
else
# For whatever reason no distribution is found, commands wil be executed either way.
    "$privilege" apt update -y && echo "Package database successfully updated. Now follows the update of the packages..." >> "$output" # Use sudo to update apt package index with automatic yes to prompts and print message
    "$privilege" apt upgrade && echo "All updates have been successfully completed." >> "$output" && "$privilege" apt purge --auto-remove # Use sudo to upgrade and remove unnecessary packages for other distributions
fi

echo -en "\n### Flatpaks are now being checked ### \n" >> "$output" # Print message indicating that flatpaks are being checked
"$flatpak" update 2>> "$output" # Use flatpak to update flatpak packages and append the output to the updates_info.log file

# Prompting for confirmation
echo -en "\nThese following flatpaks are no longer needed and can be uninstalled:\n" >> "$output" # Print message indicating that unnecessary flatpaks can be uninstalled

# Remove unused/leftover flatpaks
"$flatpak" uninstall --unused 2>> "$output" || echo "Flatpak is not installed on the system" >> "$output" # Use flatpak to uninstall unused/leftover flatpaks and append the output to the updates_info.log file, or print a message if flatpak is not installed