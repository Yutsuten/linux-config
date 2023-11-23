function share --description 'Share screen or phone camera using v4l2loopback'
    argparse --min-args 1 --max-args 1 'h/help' 'f/flip' -- $argv
    or return

    if set --query --local _flag_help
        echo 'Usage: share [camera|screen]' >&2
        return 1
    end

    sudo modprobe -r v4l2loopback
    sudo modprobe v4l2loopback
    sleep 0.1
    set flip
    switch $argv[1]
        case camera
            if set --query --local _flag_flip
                set flip -hflip
            end
            droidcam-cli $flip 192.168.0.110 4747
        case screen
            if set --query --local _flag_flip
                set flip -F hflip
            end
            wf-recorder --muxer=v4l2 --codec=rawvideo --file=/dev/video0 -x yuv420p $flip
        case '*'
            echo 'Usage: share [camera|screen]' >&2
            return 1
    end
end
