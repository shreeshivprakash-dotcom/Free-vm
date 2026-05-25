#!/bin/bash
# Fetch the repository name dynamically
REPO_NAME=$(basename $(pwd))
PERSISTENT_DIR="/workspaces/$REPO_NAME/.gui-persistent-data"

# Create the hidden persistent architecture folders
mkdir -p "$PERSISTENT_DIR/apps"
mkdir -p "$PERSISTENT_DIR/config"
mkdir -p "$PERSISTENT_DIR/local-share"

# Symlink system configurations so themes/data survive shutdowns
if [ ! -L "/home/vscode/.config" ]; then
    rm -rf /home/vscode/.config
    ln -s "$PERSISTENT_DIR/config" /home/vscode/.config
fi

if [ ! -L "/home/vscode/.local/share" ]; then
    mkdir -p /home/vscode/.local
    rm -rf /home/vscode/.local/share
    ln -s "$PERSISTENT_DIR/local-share" /home/vscode/.local/share
fi

# Add the persistent apps directory directly to the system executable path
if ! grep -q "$PERSISTENT_DIR/apps" /home/vscode/.bashrc; then
    echo "export PATH=\$PATH:$PERSISTENT_DIR/apps" >> /home/vscode/.bashrc
fi
