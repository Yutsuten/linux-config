export GPG_TTY=$(tty)
export ZSH="${HOME}/.oh-my-zsh"
export LC_MESSAGES=C

ZSH_THEME="yutsuten"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"
HIST_STAMPS="yyyy-mm-dd"

function precmd() {
  title $(basename $PWD)
}

plugins=(git virtualenv ssh-agent zsh-syntax-highlighting)

source "${ZSH}/oh-my-zsh.sh"
