#!/usr/bin/env bash
set -euo pipefail

USER_HOME="/home/vscode"
REPO_NAME="$(basename "$(pwd)")"
PERSIST_ROOT="/workspaces/${REPO_NAME}/.persist"
PERSIST_HOME="${PERSIST_ROOT}/home"

MARKER="${PERSIST_ROOT}/.installed_v1"

echo "==> Persistent root: ${PERSIST_ROOT}"

# -----------------------------
# 1) Persistence (safe + idempotent)
# -----------------------------
mkdir -p "${PERSIST_HOME}"/.config \
         "${PERSIST_HOME}"/.cache \
         "${PERSIST_HOME}"/.local/share \
         "${PERSIST_HOME}"/.vnc \
         "${PERSIST_ROOT}"/bin \
         "${USER_HOME}/Desktop"

# Fix ownership (Codespaces user is vscode)
sudo chown -R vscode:vscode "${PERSIST_ROOT}"

link_dir() {
  local src="$1"
  local dst="$2"
  if [ -L "${dst}" ]; then
    return 0
  fi
  if [ -e "${dst}" ] && [ ! -L "${dst}" ]; then
    rm -rf "${dst}"
  fi
  ln -s "${src}" "${dst}"
}

# Persist the main GUI/user settings
mkdir -p "${USER_HOME}/.local"
link_dir "${PERSIST_HOME}/.config"       "${USER_HOME}/.config"
link_dir "${PERSIST_HOME}/.cache"        "${USER_HOME}/.cache"
link_dir "${PERSIST_HOME}/.local/share"  "${USER_HOME}/.local/share"
link_dir "${PERSIST_HOME}/.vnc"          "${USER_HOME}/.vnc"

# -----------------------------
# 2) Install LXQt + Chromium (only once)
# -----------------------------
if ! command -v apt-get >/dev/null 2>&1; then
  echo "!! apt-get not found. This usually means the codespace is still in recovery mode."
  echo "!! Delete the codespace and create a NEW one after committing these files."
  exit 0
fi

if [ ! -f "${MARKER}" ]; then
  echo "==> Installing packages (first run only)..."
  sudo apt-get update -y

  # LXQt desktop + Chromium browser + essentials for GUI sessions
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lxqt \
    lxqt-session \
    openbox \
    dbus-x11 \
    chromium \
    ca-certificates \
    fonts-dejavu \
    xdg-utils

  touch "${MARKER}"
  echo "==> Package install complete."
else
  echo "==> Packages already installed (marker found)."
fi

# -----------------------------
# 3) Make desktop-lite start LXQt (TigerVNC uses ~/.vnc/xstartup)
# -----------------------------
XSTARTUP="${USER_HOME}/.vnc/xstartup"
cat > "${XSTARTUP}" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

export XDG_RUNTIME_DIR="/tmp/runtime-vscode"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

exec dbus-launch --exit-with-session startlxqt
EOF
chmod +x "${XSTARTUP}"

# -----------------------------
# 4) Desktop shortcut for Chromium
# -----------------------------
cat > "${USER_HOME}/Desktop/Chromium.desktop" <<EOF
[Desktop Entry]
Name=Chromium
Exec=chromium --disable-gpu --disable-dev-shm-usage
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF
chmod +x "${USER_HOME}/Desktop/Chromium.desktop"

echo "==> Setup finished. Open the desktop on port 6080 (password: vscode)."
