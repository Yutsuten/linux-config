function android-camera --description 'Use phone camera as a webcam through v4l2loopback'
    argparse --ignore-unknown h/help -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: android-camera OPTIONS' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Use phone camera as a webcam through v4l2loopback. Options are the same as droidcam-cli.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo
        echo 'Bellow is droidcam-cli help:'
        echo
        droidcam-cli -h
        return $exitcode
    end

    sudo modprobe -r v4l2loopback
    sudo modprobe v4l2loopback card_label='DroidCam' exclusive_caps=1
    sleep 0.1
    droidcam-cli -size=1920x1080 $argv
    return 0
end
