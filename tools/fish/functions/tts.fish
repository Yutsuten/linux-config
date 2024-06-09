function tts --description 'Text-to-Speech using Google API'
    argparse 'h/help' 'g/girl' -- $argv
    set exitcode $status

    if test $exitcode -ne 0 || set --query --local _flag_help
        echo 'Usage: tts [options] TEXT' >&2
        echo >&2
        echo '  Synopsis:' >&2
        echo '    Text-to-Speech using Google API.' >&2
        echo >&2
        echo '  Options:' >&2
        echo '    -h, --help      Show list of command-line options' >&2
        echo '    -g, --girl      Use woman voice instead' >&2
        echo >&2
        echo '  Positional arguments:' >&2
        echo '    TEXT            Used to generate the audio' >&2
        return $exitcode
    end

    if set --query --local _flag_girl
        set voice ja-JP-Wavenet-B
    else
        set voice ja-JP-Wavenet-C
    end
    set filename (echo {$voice}_{$argv}.ogg | tr -d '|?*<":>+[]\'\\\\' | tr ' ' '_')

    if test -f $filename
        echo "$filename already exists!" >&2
        return 1
    end

    curl --silent -X POST -H 'Content-Type:application/json' \
      -d '{"audioConfig": {"audioEncoding": "OGG_OPUS"}, "input": {"ssml": "<speak>'"$argv"'</speak>"}, "voice": {"languageCode": "ja-JP", "name": "'$voice'"}}' \
      "https://texttospeech.googleapis.com/v1/text:synthesize?key=$GOOGLE_TTS_API_KEY" \
        | jq -r .audioContent \
        | base64 --decode > $filename

    echo "$filename"
    mpv --really-quiet --volume=100 $filename
    return 0
end
