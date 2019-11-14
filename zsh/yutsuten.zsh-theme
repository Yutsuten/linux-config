# yutsuten.zsh-theme

git_custom_status() {
  local git_branch=$(git_current_branch)
  if [[ -n "${git_branch}" ]]; then
    local git_dirty=$(parse_git_dirty)
    local git_ahead=$(git_commits_ahead)
    if [[ -n "${git_dirty}" ]]; then
      echo -n "%{$fg[red]%}"
    elif [[ -n "${git_ahead}" ]]; then
      echo -n "%{$fg[yellow]%}"
    else
      echo -n "%{$fg[green]%}"
    fi
    echo -n " (${git_branch})"
  fi
}

local code="%(?.%{$fg[blue]%}.%{$fg[magenta]%})[%?] "
local user_host="%{$terminfo[bold]$fg[magenta]%}%n@%m"
local dir="%{$fg[cyan]%}%~%{$reset_color%}"

PROMPT="${code}${user_host}:${dir}\$(git_custom_status)%{$reset_color%}
%{$terminfo[bold]%}$ %{$reset_color%}"
