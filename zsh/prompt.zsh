nnn_prompt() {
  if [[ -n ${nnn} ]]; then
    echo -n "%B%F{4}[nnn]%f "
  fi
}

git_prompt() {
  local branch
  branch=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  [[ $ret == 128 ]] && return  # no git repo.

  local title
  if [[ $ret == 0 ]]; then
    if [[ -n "$(git show-ref origin/${branch#refs/heads/} 2> /dev/null)" ]]; then
      title="☁ ${branch#refs/heads/}"
    else
      title="↻ ${branch#refs/heads/}"
    fi
  else
    local label=$(git for-each-ref --points-at=HEAD --count=1 --format='%(refname:short)' refs/tags 2> /dev/null)
    if [[ -n ${label} ]]; then
      title="🏷 ${label}"
    else
      local commit_hash=$(git rev-parse --short HEAD 2> /dev/null) || return
      title="◉ ${commit_hash}"
    fi
  fi

  local color="%F{2}"
  if [[ -n $(git status --porcelain 2> /dev/null | tail -1) ]]; then
    color="%F{1}"
  elif [[ -n "$(git rev-list origin/${branch#refs/heads/}..HEAD 2> /dev/null)" ]] || [[ -n "$(git rev-list HEAD..origin/${branch#refs/heads/} 2> /dev/null)" ]]; then
    color="%F{3}"
  fi

  local extra=""
  if git rev-parse --git-dir &> /dev/null; then
    local commits_ahead="$(git rev-list --count @{upstream}..HEAD 2> /dev/null)"
    local commits_behind="$(git rev-list --count HEAD..@{upstream} 2> /dev/null)"
    if [[ -n "${commits_ahead}" && "${commits_ahead}" != 0 ]]; then
      extra+=" 🠥${commits_ahead}"
    fi
    if [[ -n "${commits_behind}" && "${commits_behind}" != 0 ]]; then
      extra+=" 🠧${commits_behind}"
    fi
  fi

  echo -n " ${color}(${title}${extra})%f"
}

local user_host="%B[%D %*] %F{13}%n@%m%b"
local curdir="%F{14}%~%f"

PROMPT="%f
\$(nnn_prompt)${user_host}:${curdir}\$(git_prompt)%f
%F{2}%(!.#.$)%{$reset_color%} "
