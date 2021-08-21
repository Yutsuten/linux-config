# yutsuten.zsh-theme

ZSH_THEME_GIT_PROMPT_DIRTY="%F{1}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_AHEAD="%F{3}"
ZSH_THEME_GIT_PROMPT_BEHIND="%F{9}"
ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX=' 🠉'
ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX=''
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX=' 🠋'
ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX=''
ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS='☁'
ZSH_THEME_GIT_PROMPT_REMOTE_MISSING='↻'

git_custom_status() {
  local git_title
  local git_branch

  git_branch=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  [[ $ret == 128 ]] && return  # no git repo.

  if [[ $ret == 0 ]]; then
    git_title="$(git_prompt_remote) ${git_branch#refs/heads/}"
  else
    local label=$(__git_prompt_git log --decorate -1 --pretty=%D HEAD 2> /dev/null | sed -E 's/^.*tag: ([^,]+).*$/\1/')
    if (__git_prompt_git rev-parse "refs/tags/${label}" > /dev/null 2>&1); then
      git_title="🏷 ${label}"
    else
      local commit_hash=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
      git_title="◉ ${commit_hash}"
    fi
  fi
  local color="%F{2}$(git_prompt_behind)$(git_prompt_ahead)$(parse_git_dirty)"
  local extra="$(git_commits_ahead)$(git_commits_behind)"
  echo -n " ${color}(${git_title}${extra})%f"
}

local new_line=$'\n'

local exit_code="%(?..%F{1}× Exit code: %?%f${new_line})"
local user_host="%B%F{13}%n@%m%b"
local curdir="%F{14}%~%f"
local venv="%F{6}\$(virtualenv_prompt_info)"

PROMPT="${exit_code}${user_host}:${curdir}\$(git_custom_status) ${venv}%f
%F{2}$%{$reset_color%} "
