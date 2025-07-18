#!/usr/bin/env fish
argparse h/help 'd/dir=' m/mic r/rec s/speakers w/waybar -- $argv
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
    return $exitcode
end

set NICE_LEVEL -5
set CONFIG_FILE ~/.config/record/config
set name $argv

# Parse configuration
if test -f $CONFIG_FILE
    while read --line line
        set key_value (string split '=' $line)
        if test (count $key_value) -le 1
            continue
        end
        if test $key_value[1] = directory
            set --global rec_dir (string join '=' $key_value[2..])
        else if test $key_value[1] = name
            set name (string join '=' $key_value[2..])
        else if $key_value[2] = true
            switch $key_value[1]
                case waybar
                    set --global rec_waybar yes
                case audio-speakers
                    set --global rec_audio_speakers yes
                case audio-mic
                    set --global rec_audio_mic yes
                case audio-recording
                    set --global rec_audio_recording yes
                case '*'
                    echo "Invalid key ignored: $key_value[0]"
            end
        end
    end <$CONFIG_FILE
end

# Process command line arguments
if set --query --local _flag_dir
    set --global rec_dir $_flag_dir
end
if set --query --local _flag_waybar
    set --global rec_waybar yes
end
if set --query --local _flag_speakers
    set --global rec_audio_speakers yes
end
if set --query --local _flag_mic
    set --global rec_audio_mic yes
end
if set --query --local _flag_rec
    set --global rec_audio_recording yes
end

# Default directory to record
if not set --query rec_dir
    set --global rec_dir ~/Videos
end

# Script start
function debug
    echo "[$(date '+%F %T.%N')] $argv"
end

function stop_recording
    debug '[VIDEO] Stop recording wayland screen'
    kill --verbose $wl_screenrec_pid

    if set --query mic_pid
        debug '[AUDIO] Stop recording mic'
        kill --verbose $mic_pid
    end
    if set --query rec_pid
        debug '[AUDIO] Stop recording "recording" source'
        kill --verbose $rec_pid
    end
    if set --query speakers_pid
        debug '[AUDIO] Stop recording speakers'
        kill --verbose $speakers_pid
    end
end

trap stop_recording SIGHUP SIGINT

set folder_name $rec_dir/(date '+%Y-%m-%d_%H-%M-%S')
if test (count $name) -ge 1
    set folder_name (string join _ $folder_name $name)
end
debug "[INFO] Recording in $folder_name/"
mkdir $folder_name || return 1

if set --query rec_audio_mic
    set node_id (wpctl status --name | sed -nE 's/^.* ([0-9]+)\. alsa_input.+analog-stereo .*$/\1/p')
    debug "[AUDIO] Mic node ID: $node_id"
    nice -n $NICE_LEVEL pw-record --channels 1 --target $node_id $folder_name/mic.flac &
    set mic_pid $last_pid
    debug "[AUDIO] Start recording mic (PID: $mic_pid)"
end
if set --query rec_audio_recording
    set node_id (wpctl status --name | sed -nE 's/^.* ([0-9]+)\. recording .*$/\1/p')
    debug "[AUDIO] Recording node ID: $node_id"
    wpctl set-volume $node_id 100%
    nice -n $NICE_LEVEL pw-record --channels 2 --target $node_id --properties 'stream.capture.sink=true' $folder_name/rec.flac &
    set rec_pid $last_pid
    debug "[AUDIO] Start recording 'recording' source (PID: $rec_pid)"
end
if set --query rec_audio_speakers
    set node_id (wpctl status --name | sed -nE 's/^.* ([0-9]+)\. alsa_output.+analog-stereo .*$/\1/p')
    debug "[AUDIO] Speakers node ID: $node_id"
    nice -n $NICE_LEVEL pw-record --channels 2 --target $node_id --properties 'stream.capture.sink=true' $folder_name/speakers.flac &
    set speakers_pid $last_pid
    debug "[AUDIO] Start recording speakers (PID: $speakers_pid)"
end

nice -n $NICE_LEVEL wl-screenrec --low-power off --filename $folder_name/video.mp4 &
set wl_screenrec_pid $last_pid
debug "[VIDEO] Start recording wayland screen (PID: $wl_screenrec_pid)"

if set --query rec_waybar
    fish --command="
    while pgrep --exact wl-screenrec &>/dev/null
        set seconds --scale 0 (math (date '+%s') - $(date '+%s'))
        set minutes --scale 0 (math \$seconds / 60)
        printf '🔴 %d:%02d:%02d - Recording\n' \
            (math --scale 0 \$minutes / 60) (math \$minutes % 60) (math \$seconds % 60) \
            >/tmp/waybar_status
        kill --signal RT1 waybar
        sleep 1s
    end
    rm --force /tmp/waybar_status
    kill --signal RT1 waybar" &
end

wait $wl_screenrec_pid $mic_pid $rec_pid $speakers_pid
debug '[INFO] Recording finished, start post-processing'

if set --query rec_audio_mic && set --query rec_audio_speakers
    debug '[AUDIO] Mixing mic and speakers'
    nice -n 5 ffmpeg -loglevel warning -i $folder_name/mic.flac -i $folder_name/speakers.flac -filter_complex 'amerge=inputs=2' -ac 2 $folder_name/mix.flac
end

debug '[INFO] Finish!'
return 0
