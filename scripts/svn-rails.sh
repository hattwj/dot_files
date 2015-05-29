#! /bin/bash --

mkdir -p ./public/assets

svn delete --keep-local log/*
svn delete --keep-local tmp/*
svn delete --keep-local db/*.sqlite3
svn delete --keep-local db/seeds/*.sql
svn delete --keep-local config/*.yml
svn delete --keep-local public/assets/*
svn delete --keep-local *.swp
svn delete --keep-local *.swo
svn delete --keep-local *.swn
svn delete --keep-local *.sql

svn update log/
svn update tmp/
svn update db/
svn update config/
svn update public/assets

# ignore test/dummy/tmp if it exists - rails engines
[ -d "test/dummy/tmp" ] && svn --force remove test/dummy/tmp/* && svn propset svn:ignore '*' test/dummy/tmp

svn propset svn:ignore '*' log/
svn propset svn:ignore '*' tmp/
[ -d "public/assets" ] && svn propset svn:ignore '*' public/assets/
[ -d "public/surveys/application/config" ] && svn propset svn:ignore 'config.php' public/surveys/application/config

svn propset --recursive svn:ignore '*.yml
*.swp
*.swo
*.swn' \
config/

svn propset --recursive svn:ignore '*.yml
*.swp
*.swo
*.swn' \
app/

svn propset svn:ignore '*.csv
*.xml
*.xls
*.xlsx
*.swp
*.swo
*.swn
*.sql
*.sqlite3
*.yml' \
./db

[ -d ./db/data ] && svn propset --recursive svn:ignore '*.csv
*.xml
*.xls
*.xlsx
*.swp
*.swo
*.swn
*.sql
*.sqlite3
*.yml
log
match
output' \
./db/data

