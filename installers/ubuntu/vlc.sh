#!/usr/bin/env bash
set -e
set -x

echo "Be sure to install flatpack first"
sudo apt remove vlc
flatpak install flathub org.videolan.VLC
