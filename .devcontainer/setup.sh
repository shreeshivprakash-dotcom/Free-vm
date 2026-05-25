#!/bin/bash
set -e

USER_HOME="/home/vscode"
PERSIST="/workspaces/$(basename "$PWD")/.persist"
BIN="$PERSIST/bin"

echo "Setting up..."

# Create dirs
mkdir -p "$PERSIST"/{config,share,bin}
sudo chown -R vscode:vscode "$PERSIST"

# Fix config persistence
rm -rf "$USER_HOME/.config"
ln -s "$PERSIST/config" "$USER_HOME/.config"

mkdir -p "$USER_HOME/.local"
rm -rf "$USER_HOME/.local/share"
ln -s "$PERSIST/share" "$USER_HOME/.local/share"

# Add bin to PATH
if ! grep -q "$BIN" "$USER_HOME/.bashrc"; then
    echo "export PATH=\$PATH:$BIN" >> "$USER_HOME/.bashrc"
fi

# ✅ Install required libs (IMPORTANT FIX)
sudo apt update
sudo apt install -y libnss3 libatk1.0-0 libgtk-3-0 libx11-xcb1 wget

# ✅ Download working portable Firefox
if [ ! -f "$BIN/firefox" ]; then
    echo "Downloading Firefox portable..."

    cd "$BIN"
    wget -O firefox.tar.bz2 \
    "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"

    tar -xjf firefox.tar.bz2
    mv firefox firefox-portable
    rm firefox.tar.bz2
fi

# ✅ Create run script
cat > "$BIN/firefox-run" <<EOF
#!/bin/bash
$BIN/firefox-portable/firefox
EOF

chmod +x "$BIN/firefox-run"

# ✅ Create desktop icon (FIXED)
mkdir -p "$USER_HOME/Desktop"

cat > "$USER_HOME/Desktop/Firefox.desktop" <<EOF
[Desktop Entry]
Name=Firefox Portable
Exec=$BIN/firefox-run
Icon=firefox
Type=Application
Categories=Network;
EOF

chmod +x "$USER_HOME/Desktop/Firefox.desktop"

echo "✅ DONE"
