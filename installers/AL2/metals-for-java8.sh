#!/usr/bin/env bash

# A metals installer for systems that have older versions of Java.

set -e 

mkdir -p "$HOME/.cache/nvim/nvim-metals/metals" || exit 1

# nvim-metals is installing the wrong version
rm "$HOME/.cache/nvim/nvim-metals/metals" || echo ''

# the last version of metals to support Java8
cs install metals:1.3.0

ln -s "$HOME/.local/share/coursier/bin/metals" "$HOME/.cache/nvim/nvim-metals/metals"

