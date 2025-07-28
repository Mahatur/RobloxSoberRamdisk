#!/bin/bash
# Sober RAM Disk Manager
# Redirects Sober (Roblox client) data to RAM disk for faster performance
# Usage: ./script (install) or ./script -r (restore)
# Coded by Claude Sonnet 4 because i suck

set -e

# Get the real user's home directory
USER_HOME=$(eval echo ~$(logname))
SOURCE_DIR="$USER_HOME/.var/app/org.vinegarhq.Sober"
BACKUP_DIR="$USER_HOME/.var/app/org.vinegarhq.Sober.backup"
RAM_DIR="$USER_HOME/sober-ramdisk"

install_ramdisk() {
    # Check if already installed
    if [ -L "$SOURCE_DIR" ] && mountpoint -q "$RAM_DIR" 2>/dev/null; then
        echo "Already installed"
        exit 0
    fi

    # Create RAM disk
    sudo mkdir -p "$RAM_DIR" 2>/dev/null
    if ! mountpoint -q "$RAM_DIR"; then
        sudo mount -t tmpfs -o size=4G,mode=755,uid=$(id -u),gid=$(id -g) tmpfs "$RAM_DIR" 2>/dev/null
    fi

    # Backup original data
    if [ -d "$SOURCE_DIR" ] && [ ! -L "$SOURCE_DIR" ]; then
        mv "$SOURCE_DIR" "$BACKUP_DIR"
    elif [ -L "$SOURCE_DIR" ]; then
        rm "$SOURCE_DIR"
    fi

    # Create target directory
    mkdir -p "$RAM_DIR/Sober"

    # Copy data with progress
    if [ -d "$BACKUP_DIR" ]; then
        TOTAL_SIZE=$(du -sb "$BACKUP_DIR" | cut -f1)
        
        if [ "$TOTAL_SIZE" -gt 0 ]; then
            rsync -a "$BACKUP_DIR/" "$RAM_DIR/Sober/" &
            RSYNC_PID=$!
            
            while kill -0 $RSYNC_PID 2>/dev/null; do
                if [ -d "$RAM_DIR/Sober" ]; then
                    COPIED_SIZE=$(du -sb "$RAM_DIR/Sober" 2>/dev/null | cut -f1 || echo "0")
                    PERCENT=$(( COPIED_SIZE * 100 / TOTAL_SIZE ))
                    echo -ne "\rProgress: $PERCENT%"
                fi
                sleep 1
            done
            echo -ne "\rProgress: 100%\n"
        fi
    fi

    # Create symlink and set permissions
    ln -sf "$RAM_DIR/Sober" "$SOURCE_DIR"
    chmod -R 755 "$RAM_DIR/Sober" 2>/dev/null
    flatpak override --nofilesystem="$RAM_DIR/Sober" org.vinegarhq.Sober 2>/dev/null || true
    flatpak override --filesystem=home org.vinegarhq.Sober 2>/dev/null

    echo "Done"
}

remove_ramdisk() {
    # Check if setup exists
    if [ ! -L "$SOURCE_DIR" ] && [ ! -d "$BACKUP_DIR" ]; then
        echo "Nothing to remove"
        exit 0
    fi

    # Save current data
    if [ -L "$SOURCE_DIR" ] && [ -d "$RAM_DIR/Sober" ]; then
        TEMP_BACKUP="$USER_HOME/.var/app/org.vinegarhq.Sober.temp"
        rsync -a "$RAM_DIR/Sober/" "$TEMP_BACKUP/" 2>/dev/null
    fi

    # Remove symlink
    if [ -L "$SOURCE_DIR" ]; then
        rm "$SOURCE_DIR"
    fi

    # Restore data
    if [ -d "$TEMP_BACKUP" ]; then
        mv "$TEMP_BACKUP" "$SOURCE_DIR"
    elif [ -d "$BACKUP_DIR" ]; then
        mv "$BACKUP_DIR" "$SOURCE_DIR"
    fi

    # Cleanup
    if mountpoint -q "$RAM_DIR" 2>/dev/null; then
        sudo umount "$RAM_DIR" 2>/dev/null
        sudo rmdir "$RAM_DIR" 2>/dev/null || true
    fi

    flatpak override --reset org.vinegarhq.Sober 2>/dev/null
    
    if [ -d "$BACKUP_DIR" ]; then
        rm -rf "$BACKUP_DIR"
    fi

    echo "Done"
}

# Execute based on argument or default to install
case "${1:-}" in
    -r)
        remove_ramdisk
        ;;
    *)
        install_ramdisk
        ;;
esac
