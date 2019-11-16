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

format_prompt() {
  local prompt_text=$(print -Pr $1$2 | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g')  # Remove colors
  local num_spaces=$(( ${COLUMNS} - ${#prompt_text} - 2 ))
  local spaces=''

  if [[ ${num_spaces} -lt 1 ]]; then
    echo -n $1
    return
  fi

  for i in {0..${num_spaces}}; do
    spaces="${spaces} "
  done

  echo -n "$1${spaces}$2"
}

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

git_current_user() {
  if [[ -n "$(git_current_branch)" ]]; then
    echo -n "%{$reset_color%}"

    local uname=$(git_current_user_name)
    local umail=$(git_current_user_email)

    if [[ ! -n "${uname}${umail}" ]]; then
      echo -n "%{$fg[magenta]%}User information not set"
    elif [[ ! -n "${umail}" ]]; then
      echo -n "$(git_current_user_name) - %{$fg[magenta]%}email not set%{$reset_color%}"
    elif [[ ! -n "${uname}" ]]; then
      echo -n "%{$fg[magenta]%}name not set%{$reset_color%} - $(git_current_user_email)"
    else
      echo -n "$(git_current_user_name) - $(git_current_user_email)"
    fi
  fi
}

local status_code="%(?.%{$fg[green]%}.%{$fg[red]%})%? ↵"
local user_host="%{$terminfo[bold]$fg[magenta]%}%n@%m"
local dir="%{$fg[cyan]%}%~"
local venv="%{$fg[cyan]%}\$(virtualenv_prompt_info)"

local prompt_left="${user_host}:${dir}\$(git_custom_status) ${venv}%{$reset_color%}"
local prompt_right="\$(git_current_user)%{$reset_color%}"

local sc=$(print -P %?)
local sc_len=${#sc}

PROMPT="\$(format_prompt \"${prompt_left}\" \"${prompt_right}\")
%(?.%{$fg[green]%}.%{$fg[red]%})$ %{$reset_color%}"
RPROMPT="${status_code}%{$reset_color%}"
