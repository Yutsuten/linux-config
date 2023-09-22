function tts --description 'Text-to-Speech using Google API'
    argparse --min-args 1 'h/help' 'b/boy' 'g/girl' -- $argv
    or return

    if set -ql _flag_help
        echo 'Usage: tts [-h|--help] [-b|--boy] [-g|--girl] TEXT' >&2
        return 0
    end

    if set -ql _flag_girl
        set voice ja-JP-Wavenet-B
    else
        set voice ja-JP-Wavenet-C
    end
    set filename {$voice}_{$argv}.ogg

    curl --silent -X POST -H 'Content-Type:application/json' \
      -d '{"audioConfig": {"audioEncoding": "OGG_OPUS"}, "input": {"ssml": "<speak>'"$argv"'</speak>"}, "voice": {"languageCode": "ja-JP", "name": "'$voice'"}}' \
      "https://texttospeech.googleapis.com/v1/text:synthesize?key=$GOOGLE_API_KEY" \
        | jq -r .audioContent \
        | base64 --decode > $filename

    echo "Output: $filename"
    mpv --really-quiet $filename &
    disown $last_pid
end
