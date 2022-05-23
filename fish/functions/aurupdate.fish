function aurupdate --description 'Update AUR packages'
    set -l count $(ls -1 ~/.local/aur | wc -l)
    set -l cur 1
    for aur_dir in ~/.local/aur/*
        set_color white
        echo "[$cur/$count] Update $(basename "$aur_dir")"
        echo '> git pull'
        set_color normal
        git -C "$aur_dir" pull

        set_color white
        echo '> makepkg'
        set_color normal
        fish -c "cd $aur_dir && makepkg -sic --needed --nocolor"

        set -l cur $(math $cur + 1)
    end
end
