function record --description 'Record screen using wf-recorder'
    argparse 'h/help' 'm/mic' 'r/rec' 's/speakers' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: record [options] [name]' >&2
        echo '  -h, --help      Show list of command-line options'
        echo '  -m, --mic       Record mic'
        echo '  -r, --rec       Record recording.monitor audio source'
        echo '  -s, --speakers  Record speakers'
        return 1
    end

    set folder_name (date '+%Y-%m-%d_%H-%M-%S')
    if test (count $argv) -ge 1
        set folder_name (string join _ $folder_name $argv)
    end
    echo "[INFO] Will record in directory $folder_name/"
    mkdir $folder_name

    if set --query --local _flag_mic
        echo '[AUDIO] Start recording mic'
        command ffmpeg -loglevel warning -nostdin -f pulse -i (pactl list short sources | sed -nE 's/^.*(alsa_input.+analog-stereo[^\s\t]*).*$/\1/p') -ac 1 $folder_name/mic.flac &
        set mic_pid $last_pid
    end
    if set --query --local _flag_rec
        echo '[AUDIO] Start recording "recording" source'
        pactl set-sink-volume recording 100%
        command ffmpeg -loglevel warning -nostdin -f pulse -i recording.monitor -ac 2 $folder_name/rec.flac &
        set rec_pid $last_pid
    end
    if set --query --local _flag_speakers
        echo '[AUDIO] Start recording speakers'
        command ffmpeg -loglevel warning -nostdin -f pulse -i (pactl list short sources | sed -nE 's/^.*(alsa_output.+analog-stereo\.monitor[^\s\t]*).*$/\1/p') -ac 2 $folder_name/speakers.flac &
        set speakers_pid $last_pid
    end

    echo '[VIDEO] Start recording wayland screen'
    nice -n -5 wf-recorder -c libx264rgb -p crf=0 -f $folder_name/video.mp4
    echo '[VIDEO] Stop recording wayland screen'

    if set --query --local _flag_mic
        echo '[AUDIO] Stop recording mic'
        kill --verbose $mic_pid
    end
    if set --query --local _flag_rec
        echo '[AUDIO] Stop recording "recording" source'
        kill --verbose $rec_pid
    end
    if set --query --local _flag_speakers
        echo '[AUDIO] Stop recording speakers'
        kill --verbose $speakers_pid
    end

    sleep 0.2
    if set --query --local _flag_mic && set --query --local _flag_speakers
        echo '[AUDIO] Mixing mic and speakers'
        nice -n 5 ffmpeg -loglevel warning -i $folder_name/mic.flac -i $folder_name/speakers.flac \
          -filter_complex '[0:a][1:a]amerge=inputs=2[outa]' -map '[outa]' -ac 2 \
          $folder_name/mix.flac
    end
    echo 'Finish!'
end
