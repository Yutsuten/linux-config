function find_wallpapers --description 'Search for images that can be used as wallpaper'
    argparse 'h/help' 'w#min-width' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: find_wallpapers [options] [DIRS]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Search for images that can be used as wallpaper.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help       Show list of command-line options' >&2
        echo '    -w, --min-width  Min width of the image to be outputted to the file' >&2
        echo >&2
        echo '  Positional arguments:' >&2
        echo "    DIRS            Directories to be included for searching" >&2
        return $exitcode
    end

    if test (count $argv) -gt 0
        set dirs $argv
    else
        set dirs .
    end
    set find_options '(' -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.png' -or -iname '*.gif' -or -iname '*.webp' -or -iname '*.svg' -or -iname '*.bmp' ')'

    if set --query --local _flag_min_width
        find $dirs -maxdepth 1 -type f $find_options -print | while read --line image
            set dimensions (string match --regex '^(\d+) (\d+)$' (identify -format '%w %h' $image)) || continue
            test $dimensions[2] -gt $dimensions[3] -a $dimensions[2] -ge $_flag_min_width && string replace --regex '^\.\/' '' $image
        end
    else
        find $dirs -maxdepth 1 -type f $find_options -print | while read --line image
            set dimensions (string match --regex '^(\d+) (\d+)$' (identify -format '%w %h' $image)) || continue
            test $dimensions[2] -gt $dimensions[3] && string replace --regex '^\.\/' '' $image
        end
    end
    return 0
end
