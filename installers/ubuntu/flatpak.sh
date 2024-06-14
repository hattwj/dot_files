#!/usr/bin/env bash
set -e
set -x

sudo apt install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrep
sudo apt install gnome-software-plugin-flatpak
echo you may need to reboot
