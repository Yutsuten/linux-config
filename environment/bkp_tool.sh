#!/bin/bash
# ------------------------- #
# Backup (and restore) tool #
# ------------------------- #

set -e
set -u
set -o pipefail

trap 'kill 0' SIGINT

CLOUD_SYNC_DIRS='Documents Pictures'
LOCAL_SYNC_DIRS='Documents Music Pictures Videos'
LOCAL_BKP_DIR='/media/hdd1'

BACKUP=1
EXPORT_GPG=0

while getopts ':rg' opt; do
  case ${opt} in
    r) BACKUP=0 ;;
    g) EXPORT_GPG=1 ;;
    *) echo 'Usage: bkp_tool [-r|-g]' >&2; exit 1 ;;
  esac
done

if ! lsblk | grep --fixed-strings --quiet "$LOCAL_BKP_DIR"; then
  echo 'FAIL: External drive not mounted.' >&2
  exit 1
fi

if [[ ${BACKUP} = 1 ]]; then
  if [[ ${EXPORT_GPG} = 1 ]]; then
    echo '> Export and encrypt GPG secret keys'
    gpg --armor --export-secret-keys 281E7046D5349560 | gpg --output "${HOME}/Documents/GPG/gpg-master-keys.asc.gpg" --yes --symmetric -
  fi

  echo '> Export taskwarrior'
  task export > "${HOME}/Documents/taskwarrior.json"

  echo '> Backup 100% Orange juice save data'
  mkdir /tmp/100OJ_Save_Data
  cp -a ~/.steam/steam/steamapps/common/'100 Orange Juice'/user* /tmp/100OJ_Save_Data
  tar --zstd -cf "${HOME}/Documents/100OJ_Save_Data.zst" -C /tmp 100OJ_Save_Data
  rm -rf /tmp/100OJ_Save_Data

  {
    echo '[Cloud sync] Start'
    for dir in ${CLOUD_SYNC_DIRS}; do
      echo "[Cloud sync] Syncing ${dir}"
      rclone sync --exclude '.*{/**,}' "${HOME}/${dir}/" "dropbox:/${dir}/"
    done
    echo '[Cloud sync] Finish'
  } &

  if [[ -d ${LOCAL_BKP_DIR} ]]; then
    {
      echo '[Local sync] Start'
      for dir in ${LOCAL_SYNC_DIRS}; do
        echo "[Local sync] Syncing ${dir}"
        rsync --archive --update --delete "${HOME}/${dir}/" "${LOCAL_BKP_DIR}/${dir}/"
      done
      echo '[Local sync] Backup osu!lazer'
      tar --zstd -cf "${LOCAL_BKP_DIR}/osu-lazer.tar.zst" -C ~/.local/share osu
      echo '[Local sync] Finish'
    } &
  fi
  wait
elif [[ -d ${LOCAL_BKP_DIR} ]]; then
  echo 'Restoring from local drive...'
  for dir in ${LOCAL_SYNC_DIRS}; do
    rsync --archive --update --delete "${LOCAL_BKP_DIR}/${dir}/" "${HOME}/${dir}/"
  done
fi
