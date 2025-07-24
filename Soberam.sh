#!/bin/bash
set -e

# Get the real user's home directory
USER_HOME=$(eval echo ~$(logname))

SOURCE_DIR="$USER_HOME/.var/app/org.vinegarhq.Sober"
RAM_DIR="$USER_HOME/sober-ramdisk"

# Create RAM disk with full permissions
# You can modify the tmpfs size. Default size=4G 
sudo mkdir -p "$RAM_DIR"
sudo mount -t tmpfs -o size=4G,mode=777 tmpfs "$RAM_DIR"

# Ensure target directory exists
mkdir -p "$RAM_DIR/Sober"

# Calculate total size in bytes
TOTAL_SIZE=$(du -sb "$SOURCE_DIR" | cut -f1)

# Start background rsync copy
rsync -a --info=progress2 "$SOURCE_DIR/" "$RAM_DIR/Sober/" &

RSYNC_PID=$!

echo "Copying files..."
# Monitor progress
while kill -0 $RSYNC_PID 2>/dev/null; do
    COPIED_SIZE=$(du -sb "$RAM_DIR/Sober" 2>/dev/null | cut -f1)
    PERCENT=$(( COPIED_SIZE * 100 / TOTAL_SIZE ))
    echo -ne "\rProgress: $PERCENT%"
    sleep 1
done

echo -e "\rProgress: 100%"

# Set permissions
chmod -R 777 "$RAM_DIR/Sober"

# Allow Flatpak to access the RAM disk version
flatpak override --filesystem="$RAM_DIR/Sober" org.vinegarhq.Sober

echo "Sober Flatpak app copied to RAM disk"
