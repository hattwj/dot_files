#!/usr/bin/env bash

# # A metals installer for systems that have older versions of Java.
# # toolbox install axe
# axe install mise
#
# mise install java@17
# mise install coursier
# mise use -g coursier
#
# # Follow instructions and give path for java17
# brazil setup --java
#
# cs install metals scala:2.12.7

set -e
set -x

mkdir -p "$HOME/.cache/nvim/nvim-metals/metals" || exit 1

# nvim-metals is installing the wrong version
rm "$HOME/.cache/nvim/nvim-metals/metals" || echo ''

# the last version of metals to support Java8
cs install metals scala:2.12.7

ln -s "$HOME/.local/share/coursier/bin/metals" "$HOME/.cache/nvim/nvim-metals/metals"
