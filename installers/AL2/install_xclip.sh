#!/bin/bash
#
# xclip installer for AL2
#
# SETUP OVERVIEW:
# This enables bidirectional clipboard between laptop and remote tmux sessions.
# When you SSH with X11 forwarding (-X or -Y), xclip bridges tmux to your laptop clipboard.
#
# PROCESS:
# 1. Build xclip from source (AL2 repos don't include it)
# 2. Install to ~/.local/bin
# 3. Configure tmux with copy-mode-vi bindings for y/Enter/MouseDragEnd1Pane
# 4. SSH must have X11 forwarding: ssh -X user@host
# 5. Verify $DISPLAY is set (should be localhost:XX.X)
#
# GOTCHAS:
# - After updating .tmux.conf, MUST reload: `tmux source-file ~/.tmux.conf`
# - If clipboard doesn't work, verify: echo "test" | xclip -in -selection clipboard
# - X11 forwarding may require sshd restart: sudo systemctl restart sshd
# - Inside tmux, verify DISPLAY is set: tmux show-environment DISPLAY
#
# USAGE IN TMUX:
# - Mouse: Select text, auto-copies on release
# - Keyboard: Ctrl+b [ to enter copy mode, v to select, y to yank
#

set -e

XCLIP_VERSION="0.13"
SRC_DIR="$HOME/.local/src"
INSTALL_DIR="$HOME/.local/bin"

echo "Installing xclip ${XCLIP_VERSION}..."

# Create directories
mkdir -p "$SRC_DIR"
mkdir -p "$INSTALL_DIR"

# Install build dependencies
echo "Installing build dependencies..."
sudo yum install -y gcc make libX11-devel libXmu-devel

# Download and extract
cd "$SRC_DIR"
if [ ! -d "xclip-${XCLIP_VERSION}" ]; then
    echo "Downloading xclip ${XCLIP_VERSION}..."
    curl -L "https://github.com/astrand/xclip/archive/${XCLIP_VERSION}.tar.gz" -o "xclip-${XCLIP_VERSION}.tar.gz"
    tar -xzf "xclip-${XCLIP_VERSION}.tar.gz"
fi

# Build and install
cd "xclip-${XCLIP_VERSION}"
echo "Building xclip..."
autoreconf -i
./configure --prefix="$HOME/.local"
make
make install

# Verify installation
if [ -x "$INSTALL_DIR/xclip" ]; then
    echo "✓ xclip installed successfully to $INSTALL_DIR/xclip"
    "$INSTALL_DIR/xclip" -version
else
    echo "✗ Installation failed"
    exit 1
fi

echo ""
echo "NEXT STEPS:"
echo "1. Ensure ~/.local/bin is in your PATH"
echo "2. Reconnect SSH with X11 forwarding: ssh -X user@host"
echo "3. Verify DISPLAY is set: echo \$DISPLAY"
echo "4. If using tmux, reload config: tmux source-file ~/.tmux.conf"
echo "5. Test: echo 'hello' | xclip -in -selection clipboard"
