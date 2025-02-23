# th-ch YouTube Music Auto Updater/Installer

A fully automated installation and update script for [th-ch/youtube-music](https://github.com/th-ch/youtube-music) on Debian-based Linux systems. This script:

✅ Automatically installs **YouTube Music** on **amd64, arm64, and armv7l** architectures.\
✅ **Checks for updates every 6 hours** and installs the latest version if available.\
✅ Uses **systemd services and timers** for automation.\
✅ **Closes and restarts the application** after an update.\
✅ Works with **Debian, Ubuntu, Pop!\_OS, Linux Mint, Raspberry Pi OS, and other Debian-based distributions**.

---

## 🚀 Installation

Run the following commands to install and enable the auto-updater:

```bash
git clone https://github.com/KaanAlper/th-ch-Youtube-Music-Auto-Updater-Installer
cd th-ch-Youtube-Music-Auto-Updater-Installer
chmod +x install_ytmusic_updater.sh
sudo ./install_ytmusic_updater.sh
```

During installation, you will be prompted to **select your system architecture**:

1. **amd64** (64-bit Intel/AMD)
2. **arm64** (64-bit ARM)
3. **armv7l** (32-bit ARM)

Select the correct option for your system, and the script will handle the rest.

---

## ⚙️ How It Works

- The script fetches the **latest release** from GitHub.
- It **compares** the installed version with the latest available version.
- If a new version is available, it:
  1. **Stops the running application** (if open).
  2. **Downloads and installs the update**.
  3. **Fixes any missing dependencies**.
  4. **Restarts the application**.
- A **systemd timer** runs the updater **every 6 hours** to keep YouTube Music up to date.

---

## 🔄 Manual Update Check

If you want to check for updates manually, run:

```bash
sudo systemctl start ytmusic-update.service
```

To see the service logs:

```bash
journalctl -u ytmusic-update.service --follow
```

---

## 🛑 Uninstall

To remove the updater and timer, run:

```bash
sudo systemctl disable --now ytmusic-update.timer ytmusic-update.service
sudo rm /etc/systemd/system/ytmusic-update.timer /etc/systemd/system/ytmusic-update.service /usr/local/bin/ytmusic_updater.sh
sudo systemctl daemon-reload
```

---

## 📝 Notes

- Ensure **wget, curl, and dpkg** are installed on your system before running the script.
- The updater only runs on **Debian-based systems**.
- The script requires **root privileges** for installation and updates.

---

## 📌 License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0) License.

🔹 Summary of the License:

✅ You are free to share and modify the script for personal use.

❌ You may NOT use this script for commercial purposes.

✅ Attribution is required if you share modified versions.

For full details, see: CC BY-NC 4.0 License.

