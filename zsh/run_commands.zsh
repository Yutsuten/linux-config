export GPG_TTY=$(tty)
export LC_MESSAGES=C
export ZSH_CONF="${HOME}/.linux_config/zsh"

setopt PROMPT_SUBST

autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z-_}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors '=*=34'

# Alt + Backspace to delete word
bindkey '^[^?' backward-kill-word

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

source "${ZSH_CONF}/prompt.zsh"
source "${ZSH_CONF}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

alias ll='ls -l'
alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias cpwd='echo -n $(pwd -P) | xclip -selection clipboard'
alias calc='task calc'
