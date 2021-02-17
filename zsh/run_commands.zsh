export GPG_TTY=$(tty)
export ZSH="${HOME}/.oh-my-zsh"

ZSH_THEME="yutsuten"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(git virtualenv ssh-agent zsh-syntax-highlighting)

source "${ZSH}/oh-my-zsh.sh"
