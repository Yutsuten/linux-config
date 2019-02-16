#!/bin/bash
#
# Some useful alias and functions

alias cpwd='echo -n $(pwd) | xclip -selection c'

branch() {
  local git_status="$(git status 2> /dev/null)"
  local on_branch="On branch ([^${IFS}]*)"
  local on_commit="HEAD detached at ([^${IFS}]*)"

  if [[ $git_status =~ $on_branch ]]; then
    local branch=${BASH_REMATCH[1]}
    echo -n ${branch}
    return 0
  elif [[ $git_status =~ $on_commit ]]; then
    local commit=${BASH_REMATCH[1]}
    echo -n ${commit}
    return 0
  fi
  return 1
}
