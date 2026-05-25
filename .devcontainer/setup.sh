#!/bin/bash
set -e

USER_HOME="/home/vscode"
PERSIST="/workspaces/$(basename "$PWD")/.persist"
BIN="$PERSIST/bin"

echo "🚀 Starting setup..."

# -------------------------
# 1. PERSISTENCE
# -------------------------
mkdir -p "$PERSIST"/{config,share,bin}
sudo chown -R vscode:vscode "$PERSIST"

rm -rf "$USER_HOME/.config"
ln -s "$PERSIST/config" "$USER_HOME/.config"

mkdir -p "$USER_HOME/.local"
rm -rf "$USER_HOME/.local/share"
ln -s "$PERSIST/share" "$USER_HOME/.local/share"

# Add local bin to PATH
if ! grep -q "$BIN" "$USER_HOME/.bashrc"; then
    echo "export PATH=\$PATH:$BIN" >> "$USER_HOME/.bashrc"
fi

# -------------------------
# 2. INSTALL LXQt (MODERN UI)
# -------------------------
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
    lxqt-core lxqt-panel openbox lxterminal \
    papirus-icon-theme arc-theme

# Use LXQt instead of XFCE
echo "startlxqt" > "$USER_HOME/.xsession"

# -------------------------
# 3. INSTALL CHROMIUM
# -------------------------
sudo apt install -y chromium-browser

# -------------------------
# 4. CREATE DESKTOP SHORTCUT
# -------------------------
mkdir -p "$USER_HOME/Desktop"

cat > "$USER_HOME/Desktop/Chromium.desktop" <<EOF
[Desktop Entry]
Name=Chromium
Exec=chromium-browser --disable-gpu --disable-software-rasterizer
Icon=chromium
Type=Application
Categories=Network;
EOF

chmod +x "$USER_HOME/Desktop/Chromium.desktop"

# -------------------------
# 5. AUTO-START BROWSER (optional but useful)
# -------------------------
mkdir -p "$USER_HOME/.config/autostart"

cat > "$USER_HOME/.config/autostart/chromium.desktop" <<EOF
[Desktop Entry]
Type=Application
Exec=chromium-browser --disable-gpu --disable-software-rasterizer
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Chromium
EOF

echo "✅ Setup Complete!"
