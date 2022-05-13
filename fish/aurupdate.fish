function aurupdate --description 'Update AUR packages'
    cd "$HOME/Packages/aur"
    set -l count $(ls -1 | wc -l)
    set -l cur 1
    for package in *
        cd "$package"

        set_color white
        echo "[$cur/$count] Update $package"
        echo '> git pull'
        set_color normal
        git pull

        set_color white
        echo '> makepkg'
        set_color normal
        makepkg -sic --needed --nocolor

        set -l cur $(math $cur + 1)
        cd ..
    end
end
