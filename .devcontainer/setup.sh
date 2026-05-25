#!/bin/bash
set -e

USER_HOME="/home/vscode"
PERSIST="/workspaces/$(basename "$PWD")/.persist"

echo "Setting up persistence at $PERSIST"

# Create persistent dirs
mkdir -p "$PERSIST"/{config,share,bin}

# Fix ownership
sudo chown -R vscode:vscode "$PERSIST"

# Link ~/.config
rm -rf "$USER_HOME/.config"
ln -s "$PERSIST/config" "$USER_HOME/.config"

# Link ~/.local/share
mkdir -p "$USER_HOME/.local"
rm -rf "$USER_HOME/.local/share"
ln -s "$PERSIST/share" "$USER_HOME/.local/share"

# Add persistent bin to PATH
if ! grep -q "$PERSIST/bin" "$USER_HOME/.bashrc"; then
    echo "export PATH=\$PATH:$PERSIST/bin" >> "$USER_HOME/.bashrc"
fi

# Install Firefox (for YouTube)
sudo apt update
sudo apt install -y firefox

echo "✅ Setup complete"
