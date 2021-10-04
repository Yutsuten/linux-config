export GPG_TTY=$(tty)
export LC_MESSAGES=C
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LINUX_CONFIG="${HOME}/.linux_config"

autoload -Uz compinit
autoload -U colors
compinit
colors

ZSH_CONF="${LINUX_CONFIG}/zsh"
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt prompt_subst           # Enable parameter expansion, command substitution and arithmetic expansion to prompt
setopt extended_history       # Record timestamp of command in HISTFILE
setopt hist_expire_dups_first # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # Ignore duplicated commands history list
setopt hist_ignore_space      # Ignore commands that start with space
setopt sharehistory           # Share history across terminals

zle_highlight=(default:fg=14) # Prompt input color

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z-_}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors '=*=39'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

source "${ZSH_CONF}/key_bindings.zsh"
source "${ZSH_CONF}/custom_commands.zsh"
source "${ZSH_CONF}/prompt.zsh"
source "${ZSH_CONF}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

alias ls='ls --color=tty'
alias ll='ls -hl'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias identify='identify -ping -precision 3'

alias cpwd='echo -n $(pwd -P) | xclip -selection clipboard'
alias calc='task calc'
