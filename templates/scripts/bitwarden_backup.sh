#!/bin/bash

SDIR={{ ssd_storage.root }}/bitwarden
DDIR=/Master/Backup/bitwarden
TMPDIR=/tmp
KEEP_DAYS=7

DB_FILE=db.sqlite3
CONFIG_FILE=config.json
ATTACH_DIR=attachments

NOW=$(date +%F-%H-%M-%S)
ARCHIVE=bwbackup-$NOW.tar.zst
DB_OWNER=$(stat -c %U:%G $SDIR/$DB_FILE)
BAK_FILES="$DB_FILE $CONFIG_FILE"

cd $TMPDIR
sqlite3 $SDIR/$DB_FILE ".backup $DB_FILE"
chown $DB_OWNER $DB_FILE
ln -s $SDIR/$CONFIG_FILE
if [ -d $SDIR/$ATTACH_DIR ]; then
  ln -s $SDIR/$ATTACH_DIR
  BAK_FILES="$BAK_FILES $ATTACH_DIR"
fi
tar cahf $ARCHIVE $BAK_FILES
chmod 400 $ARCHIVE
rm $BAK_FILES

mkdir -pm 700 $DDIR
find $DDIR -type f -mtime +$KEEP_DAYS -delete
mv $ARCHIVE $DDIR
