#!/usr/bin/env bash
# Install tree-sitter CLI on AL2023
# Compiles from source via cargo (needed for nvim-treesitter)
set -euo pipefail

if command -v tree-sitter &>/dev/null; then
  echo "tree-sitter already installed: $(tree-sitter --version)"
  exit 0
fi

# clang needed for compiling tree-sitter parsers
sudo dnf install -y clang clang-devel clang-libs

cargo install --locked tree-sitter-cli

# Remove Mason's pre-built binary if present (may have GLIBC issues)
rm -f ~/.local/share/nvim/mason/bin/tree-sitter

# Clear pre-built parser .so files so they get recompiled with local clang
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so

echo "tree-sitter installed. Restart nvim and run :TSUpdate to compile parsers."
