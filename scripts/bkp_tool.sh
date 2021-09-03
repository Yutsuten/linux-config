#!/bin/bash
# ------------------------- #
# Backup (and restore) tool #
# ------------------------- #

set -e
set -u

CLOUD_SYNC_DIRS='Documents Pictures Shared Videos'
LOCAL_SYNC_DIRS='Documents Music Pictures Shared Videos'
LOCAL_BKP_DIR="${HOME}/Mount"

BACKUP=1
EXPORT_GPG=1

while getopts ":rg" opt; do
  case ${opt} in
    r) BACKUP=0 ;;
    g) EXPORT_GPG=0 ;;
    *) echo "Usage: bkp_tool [-r|-g]"; exit 1 ;;
  esac
done

if [[ ${BACKUP} = 1 ]]; then
  if [[ ${EXPORT_GPG} = 1 ]]; then
    echo "> Export and encrypt GPG secret keys"
    gpg --armor --export-secret-keys 281E7046D5349560 | gpg --output "${HOME}/Documents/GPG/gpg-master-keys.asc.gpg" --yes --symmetric -
  fi

  echo "> Export taskwarrior"
  task export > "${HOME}/Documents/taskwarrior.json"

  for dir in ${CLOUD_SYNC_DIRS}; do
    echo "> Syncing ${dir} to dropbox"
    rclone sync --exclude '.*{/**,}' --exclude 'gamemode*.mp4' "${HOME}/${dir}/" "dropbox:/${dir}/"
  done

  if [[ -d ${LOCAL_BKP_DIR} ]]; then
    echo 'Syncing to local drive...'
    for dir in ${LOCAL_SYNC_DIRS}; do
      rsync --archive --update --delete --exclude 'gamemode*.mp4' "${HOME}/${dir}/" "${LOCAL_BKP_DIR}/${dir}/"
    done
  fi
elif [[ -d ${LOCAL_BKP_DIR} ]]; then
  echo 'Restoring from local drive...'
  for dir in ${LOCAL_SYNC_DIRS}; do
    rsync --archive --update --delete "${LOCAL_BKP_DIR}/${dir}/" "${HOME}/${dir}/"
  done
fi
