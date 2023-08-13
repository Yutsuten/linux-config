function record --description 'Record screen using wf-recorder'
    argparse 'h/help' 'm/mix' 'r/rec' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || test $_flag_h
        echo 'Usage: record [options] [name]' >&2
        echo '  -h, --help   Show list of command-line options'
        echo '  -m, --mix    Record mix.monitor (mic and speakers) audio source'
        echo '  -r, --rec    Record recording.monitor audio source'
        return 1
    end

    set folder_name (date '+%Y-%m-%d_%H-%M-%S')
    if test (count $argv) -ge 1
        set folder_name (string join _ $folder_name $argv)
    end
    echo "[INFO] Will record in directory $folder_name/"
    mkdir $folder_name

    if test $_flag_m
        echo '[AUDIO] Start redirect speakers and mic streams to mix sink'
        set speakers (pactl list short sources | sed -nE 's/^.*(alsa_output.+analog-stereo\.monitor[^\s\t]*).*$/\1/p')
        set mic (pactl list short sources | sed -nE 's/^.*(alsa_input.+analog-stereo[^\s\t]*).*$/\1/p')
        echo "  Speakers  : $speakers"
        echo "  Microphone: $mic"
        pw-loopback --capture=$speakers --capture-props='stream.capture.sink=true' --playback=mix &
        set speakers_loopback_pid $last_pid
        pw-loopback --capture=$mic --capture-props='audio.position=[FL] stream.dont-remix=true' --playback=mix --playback-props='audio.position=[MONO]' &
        set mic_loopback_pid $last_pid
        echo '[AUDIO] Start recording "mix" source'
        pactl set-sink-volume mix 100%
        command ffmpeg -loglevel warning -nostdin -f pulse -i mix.monitor $folder_name/mix.flac &
        set mix_pid $last_pid
    end

    if test $_flag_r
        echo '[AUDIO] Start recording "recording" source'
        pactl set-sink-volume recording 100%
        command ffmpeg -loglevel warning -nostdin -f pulse -i recording.monitor $folder_name/rec.flac &
        set recording_pid $last_pid
    end

    echo '[VIDEO] Start recording wayland screen'
    wf-recorder -c libx264rgb -p crf=0 -f $folder_name/video.mp4
    echo '[VIDEO] Stop recording wayland screen'

    if test $_flag_m
        echo '[AUDIO] Stop recording "mix" source'
        kill --verbose $mix_pid
        echo '[AUDIO] Stop redirect speakers and mic streams to mix sink'
        kill --verbose $speakers_loopback_pid
        kill --verbose $mic_loopback_pid
    end

    if test $_flag_r
        echo '[AUDIO] Stop recording "recording" source'
        kill --verbose $recording_pid
    end

    echo 'Finish!'
    sleep 0.1
end
