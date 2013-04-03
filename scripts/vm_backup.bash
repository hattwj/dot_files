#! /bin/bash --
LOG_FILE=/home/hattb/$(date +%Y%m%d)_rsync.log
SOURCE='/home/hattb/source/'
DEST='/media/sf_Local_Workspace/source'
rsync -av --progress --delete --log-file=$LOG_FILE $SOURCE $DEST

