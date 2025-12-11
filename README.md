# macOS Settings Transfer Scripts

Two simple scripts to move your Mac settings from one computer to another.

## What Gets Exported

- System preferences (Dock, Finder, keyboard, mouse, etc.)
- Keyboard shortcuts
- Application settings
- Installed apps list
- Homebrew packages (if you use it)
- Shell configuration (.zshrc, .bashrc, etc.)
- Git configuration
- SSH configuration
- Network settings
- Hosts file
- Login items

## How to Use

### On Your Old Mac:

1. Open Terminal
2. Run the export script:
   ```bash
   bash export_mac_settings.sh
   ```
3. This creates a folder like `mac_settings_export_20240101_120000` in your home directory
4. Optional: Create an archive to make transfer easier:
   ```bash
   tar -czf mac_settings_backup.tar.gz mac_settings_export_*
   ```
5. Transfer this folder (or archive) to your new Mac using:
   - AirDrop
   - USB drive
   - Cloud storage (Dropbox, Google Drive, etc.)
   - Email (if small enough)

### On Your New Mac:

1. Copy the exported folder to your home directory
2. If you created an archive, extract it:
   ```bash
   tar -xzf mac_settings_backup.tar.gz
   ```
3. Open Terminal
4. Run the import script:
   ```bash
   bash import_mac_settings.sh mac_settings_export_20240101_120000
   ```
   (replace the folder name with your actual folder)
5. Press Enter when prompted
6. Restart your Mac when done

## Notes

- Some settings require you to log out and back in
- Login items need to be added manually in System Settings
- The hosts file import requires admin password
- Some app-specific settings only work if the apps are installed

## Troubleshooting

If something doesn't work:
- Make sure you're using the correct folder name
- Check that the scripts have execute permissions
- Some settings may need the specific app installed first
- Try restarting your Mac after import

## What's NOT Included

These scripts don't transfer:
- Personal files (documents, photos, etc.) - use Migration Assistant for those
- Applications themselves - you'll need to reinstall them
- Passwords - these are in your keychain (use iCloud Keychain sync)
- SSH keys - copy these manually for security

## Safety

- Your existing settings are backed up before being overwritten (with .backup extension)
- The script doesn't delete anything
- You can always revert by restoring from .backup files
