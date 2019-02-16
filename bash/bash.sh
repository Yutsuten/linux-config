#!/bin/bash
#
# Customize the bash

export TZ="Asia/Tokyo"

bash_branch_color() {
  local git_status
  local tree_clean_regex

  tree_clean_regex="working (tree|directory) clean"
  git_status="$(git status 2> /dev/null)"

  if [[ ! $git_status =~ $tree_clean_regex ]]; then
    echo -e "\033[0;31m"  # Red
  elif [[ $git_status =~ "Your branch is ahead of" ]]; then
    echo -e "\033[0;33m"  # Yellow
  elif [[ $git_status =~ "nothing to commit" ]]; then
    echo -e "\033[0;32m"  # Green
  else
    echo -e "\033[38;5;95m"  # Ochre
  fi
}

bash_branch() {
  local cur_branch

  cur_branch="$(branch)"
  if [[ $? = 0 ]]; then
      printf " $(bash_branch_color)(${cur_branch})"
  fi
}

CLOCK="\[\033[01;33m\][\A]"
USER_HOST="\[\033[01;32m\]\u@\h"
WORKING_DIR="\[\033[01;34m\]\w"
PROMPT="\[\033[00m\]$ "

export PS1="${CLOCK} ${USER_HOST}:${WORKING_DIR}$(bash_branch)\n${PROMPT}"
