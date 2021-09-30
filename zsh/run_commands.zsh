export GPG_TTY=$(tty)
export LC_MESSAGES=C
export ZSH_CONF="${HOME}/.linux_config/zsh"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000

setopt PROMPT_SUBST
setopt APPENDHISTORY
setopt EXTENDED_HISTORY       # record timestamp of command in HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # ignore duplicated commands history list
setopt HIST_IGNORE_SPACE      # ignore commands that start with space

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z-_}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors '=*=34'

function precmd() {
  echo -ne "\033]0;$(basename $PWD)\007"
}

function termcolors() {
  for COLOR1 in {0..7}; do
    COLOR2=$((COLOR1+8))
    print -P "%F{${COLOR1}}Color${COLOR1}  %F{${COLOR2}}Color${COLOR2}"
  done
}

function aur_update() {
  WHITE="\033[0;37m"
  NOCOLOR="\033[0m"
  (
    cd "${HOME}/Packages/AUR"
    count=$(ls -1 | wc -l)
    cur=1
    for package in *; do
      (
        cd "${package}"
        echo -e "${WHITE}[${cur}/${count}] Building ${package}${NOCOLOR}"
        echo -e "${WHITE}> git pull${NOCOLOR}"
        git pull
        echo -e "${WHITE}> makepkg${NOCOLOR}"
        makepkg --nocolor --syncdeps --install --needed --clean || true
      )
      (( cur+=1 ))
    done
  )
}

source "${ZSH_CONF}/key-bindings.zsh"
source "${ZSH_CONF}/prompt.zsh"
source "${ZSH_CONF}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

alias ll='ls -hl'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cpwd='echo -n $(pwd -P) | xclip -selection clipboard'
alias calc='task calc'
