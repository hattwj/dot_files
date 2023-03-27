#!/usr/bin/env bash
set -e

## Kickstart to latest version of VIM
BASE=v9.0.0471.zip
VER=vim-9.0.0471
URI=https://github.com/vim/vim/archive/$BASE

[ ! -d $HOME/src ] && mkdir $HOME/src
cd $HOME/src
[ ! -f $BASE ] && wget -O $BASE $URI
unzip $BASE
cd $VER
./configure --prefix=/usr/local \
    --enable-gui=no \
    --without-x \
    --enable-multibyte \
    --with-features=huge \
    --enable-pythoninterp \
    --enable-rubyinterp \
    --enable-luainterp \
    --enable-terminal \
    --with-ruby-command=/usr/bin/ruby
make && sudo make install && echo "Looks Good! All done!" || echo "Hmm, looks like it broke"
