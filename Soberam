#!/bin/bash
set -e
set -x

# Get the real user's home directory
USER_HOME=$(eval echo ~$(logname))

SOURCE_DIR="$USER_HOME/.var/app/org.vinegarhq.Sober"
RAM_DIR="$USER_HOME/sober-ramdisk"

# Create RAM disk with full permissions
sudo mkdir -p "$RAM_DIR"
sudo mount -t tmpfs -o size=4G,mode=777 tmpfs "$RAM_DIR"

# Ensure target directory exists
mkdir -p "$RAM_DIR/Sober"

# Copy entire Flatpak app directory to RAM disk
cp -r "$SOURCE_DIR" "$RAM_DIR/Sober"

# Set permissions
chmod -R 777 "$RAM_DIR/Sober"

# Allow Flatpak to access the RAM disk version
flatpak override --filesystem="$RAM_DIR/Sober" org.vinegarhq.Sober

echo "Sober Flatpak app copied to RAM disk"
