# Neomutt icon
if not test -f /usr/share/pixmaps/neomutt.png
    wget --no-verbose --show-progress --output-document /usr/share/pixmaps/neomutt.png 'https://raw.githubusercontent.com/neomutt/neomutt/main/data/logo/neomutt-64.png'
end
