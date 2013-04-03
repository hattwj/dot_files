#!/bin/bash --

REPODIR=/var/svn
BACKUPDIR=/home/hattb/source/svn_dumps

# Get a list of all repositories
DIRS=`find $REPODIR -maxdepth 1 -mindepth 1 -type d|xargs -l basename`

# Create dumps
for D in $DIRS; do
    echo dumping $REPODIR/$D
    svnadmin dump $REPODIR/$D > $BACKUPDIR/"svndump-$D.dump"
done
