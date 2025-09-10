#!/usr/bin/env bash

sudo yum groups install -y Development\ tools
sudo yum install -y cmake
sudo yum install -y python34-{devel,pip}
sudo pip-3.4 install neovim --upgrade
(
  mkdir ~/source || echo ~/source exists
  cd ~/source || exit 1
  [ ! -d "neovim" ] &&  git clone https://github.com/neovim/neovim.git
  cd neovim || exit 1
  git fetch --all
  git checkout release-0.11 || (echo branch not found && exit 1)
  git pull
  make distclean
  make -j16  CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo rm -rf /usr/local/share/nvim/runtime
  # make CMAKE_BUILD_TYPE=Release
  sudo make install && echo yay || echo boo
)
