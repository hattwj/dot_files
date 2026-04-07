#!/usr/bin/env bash
set -e

# Fix for tmux crashing when running nvim
# https://github.com/tmux/tmux/issues/3983

cd ~/src
[ ! -d ~/src/tmux ] && git clone https://github.com/tmux/tmux.git
cd tmux

git checkout 3.6

# configure: error: "libevent not found"
sudo yum install libevent-devel

sh ./autogen.sh
./configure  --prefix /usr
make && sudo make install
