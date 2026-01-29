#!/usr/bin/env bash
# Tree-sitter CLI for nvim-treesitter on AL2
# Pre-built binaries require GLIBC 2.33+ which AL2 doesn't have
# This compiles from source using cargo

set -e

# Install clang for compiling tree-sitter parsers
sudo yum install -y clang-devel clang-libs

# Install tree-sitter CLI via cargo (requires rust/cargo already installed)
cargo install --locked tree-sitter-cli

# Remove Mason's pre-built tree-sitter binary if present (has GLIBC issues)
rm -f ~/.local/share/nvim/mason/bin/tree-sitter

# Clear any pre-built parser .so files so they get recompiled
rm -f ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so

echo "tree-sitter installed. Restart nvim and run :TSUpdate to compile parsers."
