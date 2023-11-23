function aurupdate --description 'Update AUR packages'
    echo ':: Update AUR packages'
    set packages
    set pids
    set cur 1

    # Clone/pull
    while read --line package_url
        echo $package_url | sed -nE 's#^https://aur\.archlinux\.org/([^.]+)\.git$#\1#p' | read package
        set --append packages $package
        if test -d ~/.local/aur/$package
            git -C ~/.local/aur/$package pull --quiet &
        else
            git -C ~/.local/aur clone --quiet $package_url &
        end
        set --append pids $last_pid
    end < ~/.local/aur/packages
    set packages_count (count $packages)
    wait $pids

    # Makepkg
    for package_dir in ~/.local/aur/*/
        echo $package_dir | sed -nE 's#^.+/aur/([^/]+)/$#\1#p' | read package
        if contains $package $packages
            echo "($cur/$packages_count) AUR update $package"
            fish --command "cd $package_dir && makepkg -sic --needed --nocolor"
            set cur (math $cur + 1)
        else
            echo "⚠️ Remove unused $package"
            rm --recursive --force "$package_dir"
        end
    end
end
