#!/bin/bash
# ------------------------- #
# Backup (and restore) tool #
# ------------------------- #

set -e
set -u

CLOUD_SYNC_DIRS='Documents Pictures Shared Videos'
LOCAL_SYNC_DIRS='Anki Documents Music Pictures Shared Videos'
LOCAL_BKP_DIR="${HOME}/Mount"

while getopts ":br" opt; do
  case ${opt} in
    b) BACKUP=1 ;;
    r) RESTORE=1 ;;
    *) echo "Usage: bkp_tool [-b|-r]"; exit 1 ;;
  esac
done

if [[ ${BACKUP} = 1 ]]; then
  task export > "${HOME}/Documents/taskwarrior.json"

  for dir in ${CLOUD_SYNC_DIRS}; do
    echo "> Syncing ${dir} to dropbox"
    rclone sync --exclude '.*{/**,}' "${HOME}/${dir}/" "dropbox:/${dir}/"
  done

  if [[ -d ${LOCAL_BKP_DIR} ]]; then
    echo 'Syncing to local drive...'
    for dir in ${LOCAL_SYNC_DIRS}; do
      rsync --archive --update --delete "${HOME}/${dir}/" "${LOCAL_BKP_DIR}/${dir}/"
    done
  fi
elif [[ ${RESTORE} = 1 ]] && [[ -d ${LOCAL_BKP_DIR} ]]; then
  echo 'Restoring from local drive...'
  for dir in ${LOCAL_SYNC_DIRS}; do
    rsync --archive --update --delete "${LOCAL_BKP_DIR}/${dir}/" "${HOME}/${dir}/"
  done
fi
