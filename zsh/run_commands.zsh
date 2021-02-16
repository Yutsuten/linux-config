export GPG_TTY=$(tty)
export ZSH="/home/mateus/.oh-my-zsh"

ZSH_THEME="yutsuten"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(git virtualenv ssh-agent zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh
