function process_photos --description 'Process photos from phone'
    for photo in *.jpg
        set newname (exiv2 $photo | sed -nE 's/Image timestamp : ([0-9]{4}):([0-9]{2}):([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2})/\1-\2-\3-\4-\5-\6.jpg/p')
        if test "$photo" != "$newname"
            mv "$photo" "$newname"
        end
    end
end
