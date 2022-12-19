#!/usr/bin/env bash

cd ~/Downloads
wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
chmod ugo+x ./nvim-appimage

sudo /usr/bin/yum -y install fuse
