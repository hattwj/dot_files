#! /bin/bash --
svn add ./*
svn --force remove log/*
svn --force remove tmp/*
svn --force remove db/*.sqlite3
svn --force remove config/*.yml
svn --force remove public/assets/*

svn update log/
svn update tmp/
svn update db/
svn update config/
svn update public/assets

# ignore test/dummy/tmp if it exists - rails engines
[ -d "test/dummy/tmp" ] && svn --force remove test/dummy/tmp/* && svn propset svn:ignore '*' test/dummy/tmp

svn propset svn:ignore '*' tmp/
svn propset svn:ignore '*.yml' config/
svn propset svn:ignore '*.log' log/
svn propset svn:ignore '*.sqlite3' db/
svn propset svn:ignore '*' public/assets/

echo svn commit -m "Initial commit: svn-rails script"
