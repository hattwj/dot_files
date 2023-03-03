#!/usr/bin/env bash

mkdir ~/Downloads
mkdir ~/.bin
pushd ~/Downloads && \
  wget https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -O nvim && \
  chmod ugo+x ./nvim && \
  mv ./nvim ~/.bin/nvim && \
  sudo /usr/bin/yum -y install fuse fuse-libs && \
  echo yay || echo boo
