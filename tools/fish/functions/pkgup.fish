function pkgup --description 'Update customly installed packages'
    argparse h/help l/list -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: pkgup [options] PACKAGES' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Update customly installed packages.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        return $exitcode
    end

    if set --query --local _flag_list
        echo 'droidcam osu' >&2
        return 0
    end

    for package in $argv
        switch $package
            case droidcam # DEPS: v4l2loopback-dkms linux-headers
                # More info: https://www.dev47apps.com/droidcam/linux/
                echo "Update $package"
                set ver 2.1.3
                wget --no-verbose --show-progress --output-document /tmp/droidcam_latest.zip "https://files.dev47apps.net/linux/droidcam_$ver.zip"
                if test (sha1sum /tmp/droidcam_latest.zip | cut -d' ' -f 1) != 2646edd5ad2cfb046c9c695fa6d564d33be0f38b
                    echo 'sha1sum does not match' >&2
                    return 1
                end
                unar -output-directory /tmp /tmp/droidcam_latest.zip
                rm --force -- /tmp/droidcam_latest.zip
                pushd /tmp/droidcam_latest && sudo ./install-client
                popd
                rm --recursive --force -- /tmp/droidcam_latest
            case osu
                echo "Update $package"
                wget --no-verbose --show-progress --timestamping --directory-prefix ~/.local/games/osu/ 'https://github.com/ppy/osu/releases/latest/download/osu.AppImage'
                chmod +x ~/.local/games/osu/osu.AppImage
                pushd ~/.local/games/osu && ./osu.AppImage --appimage-extract &>/dev/null
                popd
                ln --symbolic --relative --force ~/.local/games/osu/squashfs-root/AppRun ~/.local/bin/'osu!'
                ln --symbolic --relative --force ~/.local/games/osu/squashfs-root/'osu!.desktop' ~/.local/share/applications/'osu!.desktop'
                if not test -f ~/.local/share/icons/osu.png
                    mkdir --parents ~/.local/share/icons
                    cp --preserve=all ~/.local/games/osu/squashfs-root/osu.png ~/.local/share/icons/osu.png
                end
            case '*'
                echo "Unknown package $package. Skipping."
        end
    end
end
