# #!/usr/bin/env bash
# set -euo pipefail

# USER_HOME="/home/vscode"
# REPO_NAME="$(basename "$(pwd)")"
# PERSIST_ROOT="/workspaces/${REPO_NAME}/.persist"
# PERSIST_HOME="${PERSIST_ROOT}/home"

# MARKER="${PERSIST_ROOT}/.installed_v1"

# echo "==> Persistent root: ${PERSIST_ROOT}"

# # -----------------------------
# # 1) Persistence (safe + idempotent)
# # -----------------------------
# mkdir -p "${PERSIST_HOME}"/.config \
#          "${PERSIST_HOME}"/.cache \
#          "${PERSIST_HOME}"/.local/share \
#          "${PERSIST_HOME}"/.vnc \
#          "${PERSIST_ROOT}"/bin \
#          "${USER_HOME}/Desktop"

# # Fix ownership (Codespaces user is vscode)
# sudo chown -R vscode:vscode "${PERSIST_ROOT}"

# link_dir() {
#   local src="$1"
#   local dst="$2"
#   if [ -L "${dst}" ]; then
#     return 0
#   fi
#   if [ -e "${dst}" ] && [ ! -L "${dst}" ]; then
#     rm -rf "${dst}"
#   fi
#   ln -s "${src}" "${dst}"
# }

# # Persist the main GUI/user settings
# mkdir -p "${USER_HOME}/.local"
# link_dir "${PERSIST_HOME}/.config"       "${USER_HOME}/.config"
# link_dir "${PERSIST_HOME}/.cache"        "${USER_HOME}/.cache"
# link_dir "${PERSIST_HOME}/.local/share"  "${USER_HOME}/.local/share"
# link_dir "${PERSIST_HOME}/.vnc"          "${USER_HOME}/.vnc"

# # -----------------------------
# # 2) Install LXQt + Chromium (only once)
# # -----------------------------
# if ! command -v apt-get >/dev/null 2>&1; then
#   echo "!! apt-get not found. This usually means the codespace is still in recovery mode."
#   echo "!! Delete the codespace and create a NEW one after committing these files."
#   exit 0
# fi

# if [ ! -f "${MARKER}" ]; then
#   echo "==> Installing packages (first run only)..."
#   sudo apt-get update -y

#   # LXQt desktop + Chromium browser + essentials for GUI sessions
#   sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
#     lxqt \
#     lxqt-session \
#     openbox \
#     dbus-x11 \
#     chromium \
#     ca-certificates \
#     fonts-dejavu \
#     xdg-utils

#   touch "${MARKER}"
#   echo "==> Package install complete."
# else
#   echo "==> Packages already installed (marker found)."
# fi

# # -----------------------------
# # 3) Make desktop-lite start LXQt (TigerVNC uses ~/.vnc/xstartup)
# # -----------------------------
# XSTARTUP="${USER_HOME}/.vnc/xstartup"
# cat > "${XSTARTUP}" <<'EOF'
# #!/bin/sh
# unset SESSION_MANAGER
# unset DBUS_SESSION_BUS_ADDRESS

# export XDG_RUNTIME_DIR="/tmp/runtime-vscode"
# mkdir -p "$XDG_RUNTIME_DIR"
# chmod 700 "$XDG_RUNTIME_DIR"

# exec dbus-launch --exit-with-session startlxqt
# EOF
# chmod +x "${XSTARTUP}"

# # -----------------------------
# # 4) Desktop shortcut for Chromium
# # -----------------------------
# cat > "${USER_HOME}/Desktop/Chromium.desktop" <<EOF
# [Desktop Entry]
# Name=Chromium
# Exec=chromium --disable-gpu --disable-dev-shm-usage
# Icon=chromium
# Type=Application
# Categories=Network;WebBrowser;
# EOF
# chmod +x "${USER_HOME}/Desktop/Chromium.desktop"

# echo "==> Setup finished. Open the desktop on port 6080 (password: vscode)."

#!/usr/bin/env bash
set -euo pipefail

USER_HOME="/home/vscode"
REPO_NAME="$(basename "$(pwd)")"
PERSIST_ROOT="/workspaces/${REPO_NAME}/.persist"
PERSIST_HOME="${PERSIST_ROOT}/home"
MARKER="${PERSIST_ROOT}/.modern_ui_installed_v1"

echo "==> Persistent root: ${PERSIST_ROOT}"

# -----------------------------
# 1) Persistence
# -----------------------------
mkdir -p "${PERSIST_HOME}"/.config \
         "${PERSIST_HOME}"/.cache \
         "${PERSIST_HOME}"/.local/share \
         "${PERSIST_HOME}"/.vnc \
         "${PERSIST_HOME}"/.fluxbox \
         "${PERSIST_HOME}"/.config/tint2 \
         "${PERSIST_ROOT}"/bin \
         "${PERSIST_ROOT}"/wallpapers \
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
link_dir "${PERSIST_HOME}/.fluxbox"      "${USER_HOME}/.fluxbox"

# -----------------------------
# 2) Install modern UI packages (once)
# -----------------------------
if ! command -v apt-get >/dev/null 2>&1; then
  echo "!! apt-get not found. This usually means recovery mode."
  exit 0
fi

if [ ! -f "${MARKER}" ]; then
  echo "==> Installing modern UI packages..."
  sudo apt-get update -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    chromium \
    dbus-x11 \
    ca-certificates \
    fonts-dejavu \
    fonts-noto \
    xdg-utils \
    tint2 \
    feh \
    papirus-icon-theme \
    arc-theme \
    lxappearance

  touch "${MARKER}"
  echo "==> Packages installed."
else
  echo "==> Packages already installed."
fi

# -----------------------------
# 3) Safe Chromium launcher
# -----------------------------
cat > "${PERSIST_ROOT}/bin/chromium-safe" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

export DISPLAY="${DISPLAY:-:1}"
unset DBUS_SESSION_BUS_ADDRESS || true
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

exec chromium --no-sandbox --disable-dev-shm-usage --disable-gpu "$@"
EOF
chmod +x "${PERSIST_ROOT}/bin/chromium-safe"

# -----------------------------
# 4) Wallpaper
# -----------------------------
WALLPAPER="${PERSIST_ROOT}/wallpapers/modern-wallpaper.jpg"
if [ ! -f "${WALLPAPER}" ]; then
  # If you have your own wallpaper later, replace this file manually
  # For now use a simple dark background if no image exists
  :
fi

# -----------------------------
# 5) Modern tint2 panel config
# -----------------------------
mkdir -p "${USER_HOME}/.config/tint2"

cat > "${USER_HOME}/.config/tint2/tint2rc" <<'EOF'
#---- Generated tint2 config ----#

rounded = 10
border_width = 2
background_color = #111827 92
border_color = #1f2937 100

rounded = 8
border_width = 0
background_color = #1f2937 88
border_color = #000000 0

panel_items = LTSC
panel_size = 100% 42
panel_margin = 0 0
panel_padding = 10 6 10
panel_background_id = 0
wm_menu = 1
panel_dock = 0
panel_position = bottom center horizontal
panel_layer = top
panel_monitor = all
panel_shrink = 0
autohide = 0
strut_policy = follow_size

taskbar_mode = single_desktop
taskbar_padding = 6 2 6
taskbar_background_id = 0

task_padding = 10 4 10
task_background_id = 1
task_active_background_id = 1
task_icon = 1
task_text = 1
task_centered = 1
task_font = DejaVu Sans 10
task_font_color = #d1d5db 100
task_active_font_color = #ffffff 100

launcher_padding = 8 4 8
launcher_background_id = 0
launcher_icon_theme = Papirus-Dark
launcher_icon_size = 22
launcher_item_app = /usr/share/applications/chromium.desktop

systray_padding = 8 4 8
systray_background_id = 0
systray_icon_size = 20

time1_format = %H:%M
time1_font = DejaVu Sans Bold 10
time2_format = %a %d %b
time2_font = DejaVu Sans 9
clock_font_color = #f9fafb 100
clock_padding = 10 4 10
clock_background_id = 0
EOF

# -----------------------------
# 6) Fluxbox startup (modernized)
# -----------------------------
cat > "${USER_HOME}/.fluxbox/startup" <<EOF
#!/bin/sh

# Dark wallpaper / solid background fallback
if [ -f "${WALLPAPER}" ]; then
  fbsetbg -f "${WALLPAPER}" &
else
  fbsetroot -solid "#0f172a" &
fi

# Start modern panel
(tint2 &) 

# Auto-start Chromium a moment after desktop starts
(sleep 2; ${PERSIST_ROOT}/bin/chromium-safe) &

exec fluxbox
EOF
chmod +x "${USER_HOME}/.fluxbox/startup"

# -----------------------------
# 7) Fluxbox overlay tweaks (fonts/colors)
# -----------------------------
cat > "${USER_HOME}/.fluxbox/overlay" <<'EOF'
*font: DejaVu Sans-10
menu.title.font: DejaVu Sans Bold-10
menu.frame.font: DejaVu Sans-10
toolbar.clock.font: DejaVu Sans Bold-10
toolbar.workspace.font: DejaVu Sans-10
window.font: DejaVu Sans-10
EOF

# -----------------------------
# 8) GTK theme / icons for apps
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
# 9) Desktop shortcut
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

echo "==> Modern UI setup finished. Reconnect to port 6080."

