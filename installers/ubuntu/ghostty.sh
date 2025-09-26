#!/usr/bin/env bash 
sudo apt install libgtk-4-dev libadwaita-1-dev git blueprint-compiler gettext libxml2-utils

mkdir ~/source || echo ~/source exists
cd ~/source || exit 1
[ ! -d "ghostty" ] && git clone https://github.com/ghostty-org/ghostty
cd ghostty || exit 1
git pull || exit 1 
zig build -p $HOME/.local -Doptimize=ReleaseFast && echo yay || echo boo 
