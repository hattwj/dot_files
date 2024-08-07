#!/usr/bin/env bash
set -e

# Fix for tmux crashing when running nvim
# https://github.com/tmux/tmux/issues/3983

cd ~/src
[ ! -d ~/src/tmux ] && git clone https://github.com/tmux/tmux.git
cd tmux
# configure: error: "libevent not found"
sudo yum install libevent-devel

./autoconfigure
./configure --prefix ~/.local
make && make install
