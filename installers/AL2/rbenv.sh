#!/usr/bin/env bash
sudo yum install -y gcc bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel

git clone https://github.com/rbenv/rbenv.git ~/.rbenv &&
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
