function process_photos --description 'Process photos from phone'
    for photo in *.jpg
        set newname (exiv2 $photo | sed -nE 's/Image timestamp : ([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/\1-\2-\3-\4-\5-\6.webp/p')
        if test "$photo" != "$newname"
            convert "$photo" -resize '2000x2000>' -define webp:method=6 "$newname"
        end
    end
    trash-put *.jpg
end
