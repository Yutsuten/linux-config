if status is-interactive
    # Commands to run in interactive sessions can go here
    set -g PATH $PATH:$HOME/.local/bin:$HOME/.yarn/bin
    set -g GPG_TTY $(tty)
end
