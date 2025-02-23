#!/bin/bash

# Architecture selection
echo "Please select your system architecture:"
echo "1) amd64 (64-bit Intel/AMD)"
echo "2) arm64 (64-bit ARM)"
echo "3) armv7l (32-bit ARM)"
read -p "Your choice (1/2/3): " ARCH_CHOICE

case "$ARCH_CHOICE" in
    1) FILE_TYPE="amd64.deb" ;;
    2) FILE_TYPE="arm64.deb" ;;
    3) FILE_TYPE="armv7l.deb" ;;
    *) echo "⛔ Invalid choice! Exiting."; exit 1 ;;
esac

# Installation paths
SCRIPT_PATH="/usr/local/bin/ytmusic_updater.sh"
SERVICE_PATH="/etc/systemd/system/ytmusic-update.service"
TIMER_PATH="/etc/systemd/system/ytmusic-update.timer"

# Create the update script
echo "📜 Creating update script..."
cat << EOF | sudo tee $SCRIPT_PATH > /dev/null
#!/bin/bash

REPO="th-ch/youtube-music"
FILE_TYPE="$FILE_TYPE"

# Get the installed version
INSTALLED_VERSION=\$(dpkg -s youtube-music 2>/dev/null | grep '^Version:' | awk '{print \$2}')

# If YouTube Music is not installed, it's the first installation
if [ -z "\$INSTALLED_VERSION" ]; then
    echo "YouTube Music is not installed, performing first-time installation..."
    INSTALLED_VERSION="0"
fi

# Get the latest version from GitHub
LATEST_VERSION=\$(curl -s "https://api.github.com/repos/\$REPO/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4 | tr -d 'v')

echo "Installed version: \$INSTALLED_VERSION"
echo "Latest version on GitHub: \$LATEST_VERSION"

# If versions are the same, no update is needed
if [ "\$INSTALLED_VERSION" == "\$LATEST_VERSION" ]; then
    echo "The system is already up to date."
    exit 0
fi

echo "New version found! Updating..."

# Close the running application
if pgrep -x "youtube-music" > /dev/null; then
    echo "YouTube Music is running, stopping it..."
    pkill -9 youtube-music
fi

# Download the latest version
LATEST_RELEASE=\$(curl -s "https://api.github.com/repos/\$REPO/releases/latest" | grep "browser_download_url" | grep "\$FILE_TYPE" | cut -d '"' -f 4)

# If URL is empty, show an error
if [ -z "\$LATEST_RELEASE" ]; then
    echo "Failed to retrieve download link from GitHub! Update failed."
    exit 1
fi

echo "Downloading: \$LATEST_RELEASE"
wget -O youtube-music-latest.deb "\$LATEST_RELEASE"

# Check if download was successful
if [ ! -s youtube-music-latest.deb ]; then
    echo "Download failed! Update could not be performed."
    rm -f youtube-music-latest.deb
    exit 1
fi

echo "Installing update..."
sudo dpkg -i youtube-music-latest.deb
sudo apt -f install -y  # Fix dependencies

# Restart the updated application
nohup youtube-music &

echo "Update completed!"
rm -f youtube-music-latest.deb
EOF

# Make the script executable
sudo chmod +x $SCRIPT_PATH

# Create the systemd service
echo "⚙️ Creating systemd service..."
cat << EOF | sudo tee $SERVICE_PATH > /dev/null
[Unit]
Description=YouTube Music Auto Updater
After=network.target

[Service]
ExecStart=$SCRIPT_PATH
User=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Create the systemd timer (checks for updates every 6 hours)
echo "⏳ Creating systemd timer..."
cat << EOF | sudo tee $TIMER_PATH > /dev/null
[Unit]
Description=YouTube Music Auto Updater Timer

[Timer]
OnBootSec=10min
OnUnitActiveSec=6h
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Enable the systemd service and timer
echo "🚀 Enabling service and timer..."
sudo systemctl daemon-reload
sudo systemctl enable ytmusic-update.service
sudo systemctl enable ytmusic-update.timer
sudo systemctl start ytmusic-update.timer

#Run the first update
echo "🚀 Running first update..."
sudo systemctl start ytmusic-update.service

echo "✅ Installation complete! Updates will be checked every 6 hours."
