#!/bin/bash

TARGET=syncoid@{{ offsite_backup.host }}
PORT={{ offsite_backup.port }}
TARGET_ROOT={{ offsite_backup.target }}
DATASETS="{{ offsite_backup.datasets | join(' ') }}"

# Only <, > and & need escaping in Telegram's HTML mode
html_escape () {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' <<< "$1"
}

tg_notify () {
  telegram-send -m HTML "<b>[offsite backup]</b> $1"
}

# Mutex in case something breaks and previous backup gets stuck. Also useful
# for the initial backup because that will take a few days.
exec 9>/run/offsite_backup.lock
if ! flock -n 9; then
  tg_notify "Previous off-site sync is still running, skipping."
  exit 0
fi

if ! HEALTH=$(ssh -p $PORT $TARGET zpool status -x 2>&1); then
  tg_notify "Couldn't check pool health on baobab!"
elif [ "$HEALTH" != "all pools are healthy" ]; then
  tg_notify "Pool on baobab is not healthy!<pre>$(html_escape "$HEALTH")</pre>"
fi

# Supress progress bar for cron runs.
[ -t 1 ] || QUIET=--quiet

# From `syncoid --help`:
#   --no-sync-snap     Does not create new snapshot, only transfers existing
#   --use-hold         Adds a hold to the newest snapshot on the source and
#                      target after replication succeeds and removes the hold
#                      after the next successful replication. The hold name
#                      includes the identifier if set. This allows for separate
#                      holds in case of multiple targets.
#   --no-rollback      Does not rollback snapshots on target (it probably
#                      requires a readonly target)
#
# Reasoning for the flags chosen:
# --no-sync-snap
# We want sanoid to create and manage our snapshots, not syncoid.
#
# --use-hold
# Kinda what it says on the tin. Useful in case baobab is offline for extended
# periods of time because sanoid on NAS could delete the source snapshot in the
# meantime and syncoid then wouldn't have anything to reference for the
# incremental send. That can't happen with this flag because held snapshots
# cannot be destroyed so sanoid just emits a warning and tries again later.
# Also this could theoretically let us do backups on more than one machine
# if we want to?
# https://openzfs.github.io/openzfs-docs/man/master/8/zfs-hold.8.html
#
# --no-rollback
# We never want syncoid to do rollback on baobab and its user doesn't have
# permissions for that anyway so the sync would fail without this.
#
# --sendoptions=w
# Do a raw zfs send. Important because we don't want zfs to decrypt data before
# sending them off.
# https://openzfs.github.io/openzfs-docs/man/master/8/zfs-send.8.html#w
#
# --source-bwlimit
# The network at my mom's place is slow and I don't want to saturate it.
for DS in $DATASETS; do
  syncoid $QUIET \
    --no-sync-snap --use-hold --no-rollback --no-privilege-elevation \
    --sendoptions=w --compress=none \
    --source-bwlimit={{ offsite_backup.bwlimit }} --sshport=$PORT \
    "$DS" "$TARGET:$TARGET_ROOT/$(basename "$DS")" \
    || tg_notify "Off-site sync of $(html_escape "$DS") failed!"
done
