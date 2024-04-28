function aurupdate --description 'Update AUR packages'
    argparse --max-args 0 'h/help' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: aurupdate [options]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Update AUR packages.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return 0
    end

    set bold (tput bold)
    set reset (tput sgr0)

    echo $bold':: Update AUR packages'$reset
    set packages
    set pids
    set cur 1

    # Clone/pull
    while read --line package_url
        set package (echo $package_url | sed -nE 's#^https://aur\.archlinux\.org/([^.]+)\.git$#\1#p')
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
        set package (echo $package_dir | sed -nE 's#^.+/aur/([^/]+)/$#\1#p')
        if contains $package $packages
            echo $bold"($cur/$packages_count) AUR update $package"$reset
            fish --command "cd $package_dir && makepkg -sic --needed --nocolor"
            set cur (math $cur + 1)
        else
            echo $bold"⚠️ Remove unused $package"$reset
            rm --recursive --force "$package_dir"
        end
    end
    echo $bold'Finish!'$reset
    return 0
end
