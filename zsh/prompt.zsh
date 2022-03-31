nnn_prompt() {
  if [[ -n ${nnn} ]]; then
    echo -n "%B%F{4}[nnn]%f "
  fi
}

git_prompt() {
  local branch
  branch=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  [[ $ret -eq 128 ]] && return  # no git repo.

  local title
  if [[ ${ret} -eq 0 ]]; then
    title="${branch#refs/heads/}"
  else
    local label=$(git for-each-ref --points-at=HEAD --count=1 --format='%(refname:short)' refs/tags 2> /dev/null)
    if [[ -n ${label} ]]; then
      title="🏷 ${label}"
    else
      local commit_hash=$(git rev-parse --short HEAD 2> /dev/null) || return
      title="#${commit_hash}"
    fi
  fi
  echo -n " %F{7}(${title})%f"
}

local user_host="%B[%D %*] %F{6}%n@%m%b"
local curdir="%F{14}%~%f"

PROMPT="%f
\$(nnn_prompt)${user_host}:${curdir}\$(git_prompt)%f
%F{2}%(!.#.$)%{$reset_color%} "
