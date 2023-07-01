function aurupdate --description 'Update AUR packages'
    echo ':: Update AUR packages'
    pyenv global system
    set -l count $(ls -1 ~/.local/aur | wc -l)
    set -l cur 1
    for aur_dir in ~/.local/aur/*
        echo "($cur/$count) Check updates for $(basename $aur_dir)"
        echo 'git pull'
        git -C "$aur_dir" pull
        echo 'makepkg'
        fish -c "cd $aur_dir && makepkg -sic --needed --nocolor"
        echo
        set -l cur $(math $cur + 1)
    end
end
