#!/usr/bin/env bash
set -e


[ ! -d "$HOME/src" ] && mkdir "$HOME/src"
cd "$HOME/src"
[ ! -f "$BASE" ] && git clone https://github.com/Wilfred/difftastic.git
tar xzvf "$BASE"
cd "$VER"
