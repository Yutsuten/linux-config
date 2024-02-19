function record --description 'Record screen and audio on wayland'
    argparse 'h/help' 'm/mic' 'r/rec' 's/speakers' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: record [options] [NAME]' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Record screen and audio on wayland.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo '    -m, --mic       Record mic' >&2
        echo '    -r, --rec       Record recording.monitor audio source' >&2
        echo '    -s, --speakers  Record speakers' >&2
        echo >&2
        echo '  Positional arguments:' >&2
        echo "    NAME            Appended to the output's folder name, which starts with a timestamp" >&2
        return 1
    end

    set bold (tput bold)
    set reset (tput sgr0)

    set folder_name (date '+%Y-%m-%d_%H-%M-%S')
    if test (count $argv) -ge 1
        set folder_name (string join _ $folder_name $argv)
    end
    echo $bold"[INFO] Will record in directory $folder_name/"$reset
    mkdir $folder_name

    if set --query --local _flag_mic
        echo $bold'[AUDIO] Start recording mic'$reset
        command ffmpeg -loglevel warning -nostdin -f pulse -i (pactl list short sources | sed -nE 's/^.*(alsa_input.+analog-stereo[^\s\t]*).*$/\1/p') -ac 1 $folder_name/mic.flac &
        set mic_pid $last_pid
    end
    if set --query --local _flag_rec
        echo $bold'[AUDIO] Start recording "recording" source'$reset
        pactl set-sink-volume recording 100%
        command ffmpeg -loglevel warning -nostdin -f pulse -i recording.monitor -ac 2 $folder_name/rec.flac &
        set rec_pid $last_pid
    end
    if set --query --local _flag_speakers
        echo $bold'[AUDIO] Start recording speakers'$reset
        command ffmpeg -loglevel warning -nostdin -f pulse -i (pactl list short sources | sed -nE 's/^.*(alsa_output.+analog-stereo\.monitor[^\s\t]*).*$/\1/p') -ac 2 $folder_name/speakers.flac &
        set speakers_pid $last_pid
    end

    echo $bold'[VIDEO] Start recording wayland screen'$reset
    nice -n -5 wf-recorder -c libx264rgb -p crf=0 -f $folder_name/video.mp4
    echo $bold'[VIDEO] Stop recording wayland screen'$reset

    if set --query --local _flag_mic
        echo $bold'[AUDIO] Stop recording mic'$reset
        kill --verbose $mic_pid
    end
    if set --query --local _flag_rec
        echo $bold'[AUDIO] Stop recording "recording" source'$reset
        kill --verbose $rec_pid
    end
    if set --query --local _flag_speakers
        echo $bold'[AUDIO] Stop recording speakers'$reset
        kill --verbose $speakers_pid
    end

    sleep 0.2
    if set --query --local _flag_mic && set --query --local _flag_speakers
        echo $bold'[AUDIO] Mixing mic and speakers'$reset
        nice -n 5 ffmpeg -loglevel warning -i $folder_name/mic.flac -i $folder_name/speakers.flac -filter_complex 'amerge=inputs=2' -ac 2 $folder_name/mix.flac
    end
    echo $bold'Finish!'$reset
    return 0
end
