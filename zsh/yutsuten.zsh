# yutsuten.zsh-theme

ZSH_THEME_GIT_PROMPT_DIRTY="%F{1}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_AHEAD="%F{3}"
ZSH_THEME_GIT_PROMPT_BEHIND="%F{9}"
ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX='+'
ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX=''
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX='-'
ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX=''
ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS=''
ZSH_THEME_GIT_PROMPT_REMOTE_MISSING='#'

git_custom_status() {
  local git_branch=$(git_current_branch)
  if [[ -n "${git_branch}" ]]; then
    local color="%F{2}$(git_prompt_behind)$(git_prompt_ahead)$(parse_git_dirty)"
    local branch="$(git_prompt_remote)${git_branch}"
    local extra="$(git_commits_ahead)$(git_commits_behind)"
    echo -n " ${color}(${branch}${extra})%f"
  fi
}

local new_line=$'\n'

local exit_code="%(?..%F{1}× Exit code: %?%f${new_line})"
local user_host="%B%F{13}%n@%m%b"
local curdir="%F{14}%~%f"
local venv="%F{6}\$(virtualenv_prompt_info)"

PROMPT="${exit_code}${user_host}:${curdir}\$(git_custom_status) ${venv}%f
%F{2}$%{$reset_color%} "
