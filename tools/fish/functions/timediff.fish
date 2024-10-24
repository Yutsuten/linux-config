# Useful when using ffmpeg to calculate the total time of a part of a video,
# then we use the value to add a fade out effect at the end.
# Differently to `date`, this also accepts milliseconds.

function timediff --description 'Calculate the difference between two times in seconds'
    if test (count $argv) -ne 2
        echo 'Two times must be passed as arguments.' >&2
        return 1
    end
    function time_to_sec
        set time_split (string split ':' $argv[1])
        set split_count (count $time_split)
        set total 0
        for i in (seq $split_count)
            set exp (math $split_count - $i)
            set total (math "$total + $time_split[$i] * 60^$exp")
        end
        echo $total
    end
    math abs (time_to_sec $argv[1]) - (time_to_sec $argv[2])
end
