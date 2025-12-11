#!/bin/bash

# macOS Settings Import Script
# This script imports settings exported from another Mac

set -e

# Check if export directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_exported_settings_directory>"
    echo "Example: $0 ~/mac_settings_export_20240101_120000"
    exit 1
fi

IMPORT_DIR="$1"

if [ ! -d "$IMPORT_DIR" ]; then
    echo "Error: Directory $IMPORT_DIR does not exist"
    exit 1
fi

echo "Importing macOS settings from: $IMPORT_DIR"
echo "================================================"
echo "WARNING: This will modify your system preferences."
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Import specific preference domains
echo "Importing preference domains..."
if [ -d "$IMPORT_DIR/domains" ]; then
    for plist in "$IMPORT_DIR/domains"/*.plist; do
        if [ -f "$plist" ]; then
            domain=$(basename "$plist" .plist)
            echo "  Importing $domain..."
            defaults import "$domain" "$plist" 2>/dev/null || echo "  Could not import $domain (may require specific apps)"
        fi
    done
fi

# Import Dock settings
if [ -f "$IMPORT_DIR/dock_settings.plist" ]; then
    echo "Importing Dock settings..."
    defaults import com.apple.dock "$IMPORT_DIR/dock_settings.plist" 2>/dev/null || true
    killall Dock 2>/dev/null || true
fi

# Import keyboard shortcuts
if [ -f "$IMPORT_DIR/keyboard_shortcuts.plist" ]; then
    echo "Importing keyboard shortcuts..."
    defaults import com.apple.symbolichotkeys "$IMPORT_DIR/keyboard_shortcuts.plist" 2>/dev/null || true
fi

# Import Homebrew packages if Brewfile exists
if [ -f "$IMPORT_DIR/Brewfile" ]; then
    echo "Found Homebrew bundle file..."
    if command -v brew &> /dev/null; then
        echo "Installing Homebrew packages (this may take a while)..."
        brew bundle --file="$IMPORT_DIR/Brewfile"
    else
        echo "Homebrew not installed. Skipping package installation."
        echo "To install Homebrew, visit: https://brew.sh"
    fi
fi

# Import SSH config
if [ -f "$IMPORT_DIR/ssh/config" ]; then
    echo "Importing SSH config..."
    mkdir -p "$HOME/.ssh"
    cp "$IMPORT_DIR/ssh/config" "$HOME/.ssh/config"
    chmod 600 "$HOME/.ssh/config"
fi

# Import shell configuration files
echo "Importing shell configuration files..."
for file in .bashrc .bash_profile .zshrc .zprofile .profile; do
    if [ -f "$IMPORT_DIR/$file" ]; then
        echo "  Copying $file..."
        # Backup existing file if it exists
        if [ -f "$HOME/$file" ]; then
            cp "$HOME/$file" "$HOME/${file}.backup"
            echo "    (backed up existing file to ${file}.backup)"
        fi
        cp "$IMPORT_DIR/$file" "$HOME/$file"
    fi
done

# Import git config
if [ -f "$IMPORT_DIR/.gitconfig" ]; then
    echo "Importing git config..."
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
        echo "  (backed up existing .gitconfig)"
    fi
    cp "$IMPORT_DIR/.gitconfig" "$HOME/.gitconfig"
fi

# Note about hosts file (requires sudo)
if [ -f "$IMPORT_DIR/hosts" ]; then
    echo ""
    echo "Hosts file found. To import (requires admin password):"
    echo "  sudo cp $IMPORT_DIR/hosts /etc/hosts"
fi

# Note about login items (manual)
if [ -f "$IMPORT_DIR/login_items.txt" ]; then
    echo ""
    echo "Login items list found at: $IMPORT_DIR/login_items.txt"
    echo "You'll need to add these manually in System Preferences > Users & Groups > Login Items"
fi

# Note about applications
if [ -f "$IMPORT_DIR/applications_list.txt" ]; then
    echo ""
    echo "Applications list found at: $IMPORT_DIR/applications_list.txt"
    echo "Use this as a reference to reinstall your applications"
fi

echo ""
echo "================================================"
echo "Import complete!"
echo ""
echo "Important notes:"
echo "1. Some changes may require logging out and back in"
echo "2. Some settings may require restarting specific applications"
echo "3. Check the exported directory for additional files you may want to review"
echo "4. Login items need to be added manually in System Settings"
echo ""
echo "You may want to restart your Mac for all changes to take effect."
