#! /bin/bash --

mkdir ./public/assets

svn add ./*
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

svn propset svn:ignore '*' tmp/
svn propset svn:ignore '*.yml' config/
svn propset svn:ignore '*' log/

[ -d ./db/data ] && svn propset --recursive svn:ignore \
    '*.csv
    *.xml
    *.xls
    *.xlsx
    *.swp
    *.sql
    *.sqlite3
    *.yml
    log
    match
    output' \
    ./db/data

svn propset svn:ignore \
    '*.csv
    *.xml
    *.xls
    *.xlsx
    *.swp
    *.sql
    *.sqlite3
    *.yml' \
    ./db

svn propset svn:ignore '*' public/assets/
svn propset --recursive svn:ignore '*.swp' \ 
    '*.swo' \
    '*.swn' \
    ./

