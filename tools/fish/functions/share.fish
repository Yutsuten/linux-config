function share --description 'Share screen or phone camera using v4l2loopback'
    argparse --max-args 3 'h/help' 'f/flip' -- $argv
    set exitcode $status

    function help
        echo 'Usage: share TARGET [IP] [PORT]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Share screen or phone camera using v4l2loopback.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo '    -f, --flip      Apply horizontal flip' >&2
        echo >&2
        echo '  Positional arguments:' >&2
        echo "    TARGET          Either 'camera' or 'screen'. If using 'camera', specify IP and PORT too." >&2
    end

    if test $exitcode -ne 0 || set --query --local _flag_help
        help
        return $exitcode
    end

    set flip
    switch $argv[1]
        case camera
            sudo modprobe -r v4l2loopback
            sudo modprobe v4l2loopback card_label='DroidCam' exclusive_caps=1
            sleep 0.1
            if set --query --local _flag_flip
                set flip -hflip
            end
            droidcam-cli $flip -size=1920x1080 $argv[2] $argv[3]
        case screen
            sudo modprobe -r v4l2loopback
            sudo modprobe v4l2loopback card_label='Wayland Screen' exclusive_caps=1
            sleep 0.1
            if set --query --local _flag_flip
                set flip -F hflip
            end
            wf-recorder --muxer=v4l2 --codec=rawvideo --file=/dev/video0 --pixel-format=yuv420p $flip
        case '*'
            help
            return 1
    end
    return 0
end
