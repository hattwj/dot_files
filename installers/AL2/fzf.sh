#!/usr/bin/env bash
set -e

cd ~/src/ || exit 1
[ ! -d ~/src/fzf ] && git clone --depth 1 https://github.com/junegunn/fzf.git
cd ./fzf
./install

ln -s ~/src/fzf/bin/fzf ~/bin/fzf


