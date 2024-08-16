#!/usr/bin/env fish
argparse 'h/help' 'd/dir=' 'm/mic' 'r/rec' 's/speakers' 'w/waybar' -- $argv
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

set config_file ~/.config/record/config

# Parse configuration
if test -f $config_file
    while read --line line
        set key_value (string split '=' $line)
        if not test (count $key_value) -eq 2
            continue
        end
        if test $key_value[1] = directory
            set --global rec_dir $key_value[2]
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
    end < $config_file
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
set bold (tput bold)
set reset (tput sgr0)

function debug
    echo $bold"[$(date '+%FT%T.%N')] $argv"$reset
end

function stop_recording
    debug '[VIDEO] Stop recording wayland screen'
    kill --verbose $wf_recorder_pid

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
trap '' SIGTERM

if set --query rec_waybar
    touch /tmp/waybar_record
    kill --signal RT1 waybar
end

set folder_name $rec_dir/(date '+%Y-%m-%d_%H-%M-%S')
if test (count $argv) -ge 1
    set folder_name (string join _ $folder_name $argv)
end
debug "[INFO] Recording in $folder_name/"
mkdir $folder_name || return 1

if set --query rec_audio_mic
    nice -n -5 pw-record --channels 1 --target (pactl list short sources | sed -nE 's/^.*(alsa_input.+analog-stereo[^\s\t]*).*$/\1/p') $folder_name/mic.flac &
    set mic_pid $last_pid
    debug "[AUDIO] Start recording mic (PID: $mic_pid)"
end
if set --query rec_audio_recording
    pactl set-sink-volume recording 100%
    # Cracklings if we use `pw-record`
    nice -n -5 parec --record --raw --channels 2 --rate 48000 --device recording.monitor $folder_name/rec.raw &
    set rec_pid $last_pid
    debug "[AUDIO] Start recording 'recording' source (PID: $rec_pid)"
end
if set --query rec_audio_speakers
    # Cracklings if we use `pw-record`
    nice -n -5 parec --record --raw --channels 2 --rate 48000 --device (pactl list short sources | sed -nE 's/^.*(alsa_output.+analog-stereo\.monitor[^\s\t]*).*$/\1/p') $folder_name/speakers.raw &
    set speakers_pid $last_pid
    debug "[AUDIO] Start recording speakers (PID: $speakers_pid)"
end

nice -n -5 wf-recorder -c libx264rgb -p crf=0 -f $folder_name/video.mp4 &
set wf_recorder_pid $last_pid
debug "[VIDEO] Start recording wayland screen (PID: $wf_recorder_pid)"

wait $wf_recorder_pid $mic_pid $rec_pid $speakers_pid
debug '[INFO] Recording finished, start post-processing'

if set --query rec_waybar
    rm --force /tmp/waybar_record
    kill --signal RT1 waybar
end

if set --query rec_audio_recording
    debug '[AUDIO] Saving recording source audio as flac'
    nice -n 5 ffmpeg -loglevel warning -f s16le -ar 48000 -ac 2 -i $folder_name/rec.raw $folder_name/rec.flac
end

if set --query rec_audio_speakers
    debug '[AUDIO] Saving speakers audio as flac'
    nice -n 5 ffmpeg -loglevel warning -f s16le -ar 48000 -ac 2 -i $folder_name/speakers.raw $folder_name/speakers.flac
end

if set --query rec_audio_mic && set --query rec_audio_speakers
    debug '[AUDIO] Mixing mic and speakers'
    nice -n 5 ffmpeg -loglevel warning -i $folder_name/mic.flac -i $folder_name/speakers.flac -filter_complex 'amerge=inputs=2' -ac 2 $folder_name/mix.flac
end
debug '[INFO] Finish!'
return 0
