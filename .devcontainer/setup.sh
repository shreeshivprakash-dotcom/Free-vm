#!/usr/bin/env bash
set -euo pipefail

USER_HOME="/home/vscode"
REPO_NAME="$(basename "$(pwd)")"
PERSIST_ROOT="/workspaces/${REPO_NAME}/.persist"
PERSIST_HOME="${PERSIST_ROOT}/home"
MARKER="${PERSIST_ROOT}/.lxqt_installed_v1"

echo "==> Persistent root: ${PERSIST_ROOT}"

# -----------------------------
# 1) Persistence
# -----------------------------
mkdir -p "${PERSIST_HOME}"/.config \
         "${PERSIST_HOME}"/.cache \
         "${PERSIST_HOME}"/.local/share \
         "${PERSIST_HOME}"/.vnc \
         "${PERSIST_HOME}"/.mozilla \
         "${PERSIST_ROOT}"/bin \
         "${USER_HOME}/Desktop"

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

mkdir -p "${USER_HOME}/.local"

link_dir "${PERSIST_HOME}/.config"       "${USER_HOME}/.config"
link_dir "${PERSIST_HOME}/.cache"        "${USER_HOME}/.cache"
link_dir "${PERSIST_HOME}/.local/share"  "${USER_HOME}/.local/share"
link_dir "${PERSIST_HOME}/.vnc"          "${USER_HOME}/.vnc"
link_dir "${PERSIST_HOME}/.mozilla"      "${USER_HOME}/.mozilla"

# -----------------------------
# 2) Install packages once
# -----------------------------
if ! command -v apt-get >/dev/null 2>&1; then
  echo "!! apt-get not found. Likely recovery mode."
  echo "!! Delete this codespace and create a fresh one after committing these files."
  exit 0
fi

if [ ! -f "${MARKER}" ]; then
  echo "==> Installing LXQt + Chromium..."
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lxqt \
    lxqt-session \
    openbox \
    dbus-x11 \
    chromium \
    pcmanfm-qt \
    qterminal \
    papirus-icon-theme \
    arc-theme \
    lxappearance \
    feh \
    xdg-utils \
    ca-certificates \
    fonts-dejavu \
    fonts-noto

  touch "${MARKER}"
  echo "==> Package install complete."
else
  echo "==> Packages already installed."
fi

# -----------------------------
# 3) Start LXQt instead of default Fluxbox
# desktop-lite uses TigerVNC, which reads ~/.vnc/xstartup
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
# 4) GTK theme / icons (modern look)
# -----------------------------
mkdir -p "${USER_HOME}/.config/gtk-3.0"

cat > "${USER_HOME}/.config/gtk-3.0/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=DejaVu Sans 10
gtk-application-prefer-dark-theme=true
EOF

cat > "${USER_HOME}/.gtkrc-2.0" <<'EOF'
gtk-theme-name="Arc-Dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="DejaVu Sans 10"
EOF

# -----------------------------
# 5) Chromium safe launcher
# -----------------------------
cat > "${PERSIST_ROOT}/bin/chromium-safe" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
unset DBUS_SESSION_BUS_ADDRESS || true
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

exec dbus-run-session -- chromium --no-sandbox --disable-dev-shm-usage --disable-gpu "$@"
EOF
chmod +x "${PERSIST_ROOT}/bin/chromium-safe"

# -----------------------------
# 6) Desktop shortcut
# -----------------------------
cat > "${USER_HOME}/Desktop/Chromium.desktop" <<EOF
[Desktop Entry]
Name=Chromium
Exec=${PERSIST_ROOT}/bin/chromium-safe
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
EOF
chmod +x "${USER_HOME}/Desktop/Chromium.desktop"

# -----------------------------
# 7) Optional autostart Chromium inside LXQt session
# -----------------------------
mkdir -p "${USER_HOME}/.config/autostart"
cat > "${USER_HOME}/.config/autostart/chromium.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Chromium
Exec=${PERSIST_ROOT}/bin/chromium-safe
X-GNOME-Autostart-enabled=true
EOF

echo "==> LXQt + Chromium setup finished."
echo "==> Reconnect to port 6080 and log in with password: vscode"
