#!/bin/bash

# macOS Settings Export Script
# This script exports various macOS settings to files that can be transferred to a new Mac

set -e

EXPORT_DIR="$HOME/mac_settings_export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXPORT_DIR"

echo "Exporting macOS settings to: $EXPORT_DIR"
echo "================================================"

# Export system preferences using defaults
echo "Exporting system preferences..."
defaults read > "$EXPORT_DIR/all_defaults.plist"

# Export specific important domains
echo "Exporting specific preference domains..."
DOMAINS=(
    "NSGlobalDomain"
    "com.apple.dock"
    "com.apple.finder"
    "com.apple.Safari"
    "com.apple.Terminal"
    "com.apple.screensaver"
    "com.apple.screencapture"
    "com.apple.menuextra.clock"
    "com.apple.mail"
    "com.apple.trackpad"
    "com.apple.mouse"
    "com.apple.keyboard"
    "com.apple.sound"
    "com.apple.systempreferences"
)

mkdir -p "$EXPORT_DIR/domains"
for domain in "${DOMAINS[@]}"; do
    defaults read "$domain" > "$EXPORT_DIR/domains/${domain}.plist" 2>/dev/null || echo "Could not export $domain"
done

# Export Dock preferences
echo "Exporting Dock layout..."
defaults export com.apple.dock "$EXPORT_DIR/dock_settings.plist" 2>/dev/null || true

# Export keyboard shortcuts
echo "Exporting keyboard shortcuts..."
defaults read com.apple.symbolichotkeys > "$EXPORT_DIR/keyboard_shortcuts.plist" 2>/dev/null || true

# Export installed applications list
echo "Exporting installed applications list..."
ls /Applications > "$EXPORT_DIR/applications_list.txt"
ls "$HOME/Applications" >> "$EXPORT_DIR/applications_list.txt" 2>/dev/null || true

# Export Homebrew packages if installed
if command -v brew &> /dev/null; then
    echo "Exporting Homebrew packages..."
    brew list --formula > "$EXPORT_DIR/brew_formula.txt"
    brew list --cask > "$EXPORT_DIR/brew_cask.txt"
    brew bundle dump --file="$EXPORT_DIR/Brewfile"
fi

# Export login items
echo "Exporting login items..."
osascript -e 'tell application "System Events" to get the name of every login item' > "$EXPORT_DIR/login_items.txt" 2>/dev/null || true

# Export network locations
echo "Exporting network configurations..."
networksetup -listallnetworkservices > "$EXPORT_DIR/network_services.txt" 2>/dev/null || true

# Export hosts file
echo "Copying hosts file..."
cp /etc/hosts "$EXPORT_DIR/hosts" 2>/dev/null || true

# Export ssh config if it exists
if [ -f "$HOME/.ssh/config" ]; then
    echo "Copying SSH config..."
    mkdir -p "$EXPORT_DIR/ssh"
    cp "$HOME/.ssh/config" "$EXPORT_DIR/ssh/config"
fi

# Export shell configuration files
echo "Copying shell configuration files..."
for file in .bashrc .bash_profile .zshrc .zprofile .profile; do
    if [ -f "$HOME/$file" ]; then
        cp "$HOME/$file" "$EXPORT_DIR/$file"
    fi
done

# Export git config
if [ -f "$HOME/.gitconfig" ]; then
    echo "Copying git config..."
    cp "$HOME/.gitconfig" "$EXPORT_DIR/.gitconfig"
fi

# Create a summary file
echo "Creating summary..."
cat > "$EXPORT_DIR/README.txt" << EOF
macOS Settings Export
Created: $(date)
Computer: $(hostname)
macOS Version: $(sw_vers -productVersion)

This directory contains exported settings from your Mac.
Use the import_mac_settings.sh script on your new Mac to restore these settings.

Contents:
- all_defaults.plist: All system preferences
- domains/: Individual preference domains
- dock_settings.plist: Dock configuration
- keyboard_shortcuts.plist: Keyboard shortcuts
- applications_list.txt: List of installed applications
- brew_formula.txt, brew_cask.txt, Brewfile: Homebrew packages (if applicable)
- login_items.txt: Login items
- network_services.txt: Network configurations
- hosts: Custom hosts file entries
- ssh/: SSH configuration
- Shell config files (.bashrc, .zshrc, etc.)
- .gitconfig: Git configuration

Note: Some settings may require administrator privileges to restore.
EOF

echo "================================================"
echo "Export complete!"
echo "Settings saved to: $EXPORT_DIR"
echo ""
echo "To transfer to new Mac:"
echo "1. Copy the entire folder to your new Mac"
echo "2. Run the import_mac_settings.sh script"
echo ""
echo "You may want to create an archive:"
echo "  tar -czf mac_settings_backup.tar.gz $(basename $EXPORT_DIR)"
