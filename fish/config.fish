if status is-interactive
    # Commands to run in interactive sessions can go here
    set -U fish_user_paths ~/.local/bin ~/.yarn/bin
    set -g GPG_TTY $(tty)
end
