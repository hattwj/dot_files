#!/usr/bin/env bash

set -e

git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

cd ~/.rbenv
git pull
cd plugins/ruby-build
git pull
