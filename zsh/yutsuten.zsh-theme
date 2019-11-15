# yutsuten.zsh-theme

ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[yellow]%}"
ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX='+'
ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX=''
ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX='-'
ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX=''
ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS=''
ZSH_THEME_GIT_PROMPT_REMOTE_MISSING='#'

git_custom_status() {
  local git_branch=$(git_current_branch)
  if [[ -n "${git_branch}" ]]; then
    # Color
    echo -n "%{$reset_color%} "
    echo -n "%{$fg[green]%}$(git_prompt_behind)$(git_prompt_ahead)$(parse_git_dirty)"

    # Text
    echo -n "($(git_prompt_remote)${git_branch}$(git_commits_ahead)$(git_commits_behind))"
  fi
}

local code="%(?.%{$fg[blue]%}.%{$fg[magenta]%})[%?]"
local user_host="%{$terminfo[bold]$fg[magenta]%}%n@%m"
local dir="%{$fg[cyan]%}%~"

PROMPT="${code} ${user_host}:${dir}\$(git_custom_status)%{$reset_color%}
%{$fg[white]%}$ %{$reset_color%}"
