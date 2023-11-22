function share --description 'Share screen or phone camera using v4l2loopback'
    if test (count $argv) -eq 0 || test $argv[1] != 'camera' && test $argv[1] != 'screen'
        echo 'Usage: share [camera|screen]' >&2
        return 1
    end
    sudo modprobe -r v4l2loopback
    sudo modprobe v4l2loopback
    sleep 0.1
    if test $argv[1] = 'camera'
        droidcam-cli -hflip 192.168.0.110 4747
    else if test $argv[1] = 'screen'
        yes | wf-recorder --muxer=v4l2 --codec=rawvideo --file=/dev/video0 -x yuv420p -F hflip -t
    else
        echo 'Usage: share [camera|screen]' >&2
        return 1
    end
end
