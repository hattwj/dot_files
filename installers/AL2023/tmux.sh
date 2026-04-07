#!/usr/bin/env bash
set -e

# Fix for tmux 3.2a segfaults with mouse/copy-pipe over SSH on AL2023.
# System tmux (3.2a) crashes in tty_cmd_setselection → tty_putcode_ptr2.
# https://github.com/tmux/tmux/issues/3983

if tmux -V 2>/dev/null | grep -q "^tmux 3\.[6-9]\|^tmux [4-9]"; then
  echo "tmux already up-to-date: $(tmux -V)"
  exit 0
fi

sudo dnf install -y libevent-devel

mkdir -p ~/src
cd ~/src
[ ! -d ~/src/tmux ] && git clone https://github.com/tmux/tmux.git
cd tmux

git fetch --tags
git checkout 3.6

sh ./autogen.sh
./configure --prefix /usr
make -j"$(nproc)"
sudo make install

echo "Installed: $(tmux -V)"
echo "NOTE: Kill any running tmux servers to pick up the new binary (tmux kill-server)"
